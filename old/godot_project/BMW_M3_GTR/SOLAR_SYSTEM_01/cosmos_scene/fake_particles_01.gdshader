shader_type spatial;

render_mode unshaded, blend_add, cull_back, depth_prepass_alpha;

uniform sampler2D base_texture : source_color;
uniform float rotation_speed = 1.0;
uniform float emission_strength = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Albedo color tint
uniform float transparency_threshold : hint_range(0.0, 1.0) = 0.1; // Threshold for black areas to be transparent

// Vertex shader: Apply billboard transformation
void vertex() {
    // Apply billboard transformation to ensure the object always faces the camera
    mat4 billboard_matrix = mat4(
        vec4(VIEW_MATRIX[0].xyz, 0.0), // X-axis
        vec4(VIEW_MATRIX[1].xyz, 0.0), // Y-axis
        vec4(VIEW_MATRIX[2].xyz, 0.0), // Z-axis
        vec4(0.0, 0.0, 0.0, 1.0)       // Translation stays the same
    );
    
    // Apply the billboard transformation to the model matrix
    vec4 world_position = billboard_matrix * vec4(VERTEX.xyz, 1.0);
    VERTEX = world_position.xyz;
}

// Fragment shader: Apply rotation and texture processing
void fragment() {
    vec2 uv = UV;

    // Time-dependent rotation
    float time = TIME * rotation_speed;
    vec2 center = vec2(0.5);

    float angle_cw = -time;
    float angle_ccw = time;

    mat2 rot_cw = mat2(
        vec2(cos(angle_cw), -sin(angle_cw)),
        vec2(sin(angle_cw),  cos(angle_cw))
    );

    mat2 rot_ccw = mat2(
        vec2(cos(angle_ccw), -sin(angle_ccw)),
        vec2(sin(angle_ccw),  cos(angle_ccw))
    );

    vec2 uv_cw = rot_cw * (uv - center) + center;
    vec2 uv_ccw = rot_ccw * (uv - center) + center;

    // Sampling both rotated textures
    vec4 color_cw = texture(base_texture, uv_cw);
    vec4 color_ccw = texture(base_texture, uv_ccw);

    // Mixing both rotated textures
    vec4 final_color = mix(color_cw, color_ccw, 0.5);
    final_color.rgb *= emission_strength;
    final_color.a *= alpha;

    // Apply albedo color tint
    final_color.rgb *= albedo_color.rgb;

    // Transparency: Make black areas transparent based on the threshold
    float transparency = step(transparency_threshold, max(final_color.r, max(final_color.g, final_color.b)));
    final_color.a *= transparency;

    // Final color output
    ALBEDO = final_color.rgb;
    EMISSION = final_color.rgb * emission_strength;
    ALPHA = final_color.a;
}
