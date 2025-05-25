shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color;
uniform float outline_width = 1.0;

void vertex() {
    // Transform the vertex position to clip space
    vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));

    // Get the normal in world space and transform it to view space
    vec3 view_normal = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);

    // Offset the position along the view normal, in screen space
    vec2 offset = normalize(view_normal.xy) * outline_width * clip_position.w;

    // Apply the offset to the vertex position
    clip_position.xy += offset;

    POSITION = clip_position;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    if (outline_color.a < 1.0) {
        ALPHA = outline_color.a;
    }
}
