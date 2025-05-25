shader_type spatial;

uniform sampler2D source_texture_1;
uniform vec4 source_color_2 : source_color;
uniform float emission_strength;
uniform float gradient_scale;
uniform float time_speed = 1.0;
uniform float alpha_gradient_scale = 1.0;
uniform vec2 gradient_direction = vec2(0.0, 1.0); // Default to vertical gradient
uniform float edge_falloff = 1.0; // Controls edge fading strength

// New edge falloff from all sides
uniform float edge_falloff_all_sides = 1.0; // Falloff from all edges

// Noise function
float noise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Sample the texture at the current UV coordinates
    vec4 texture_color_1 = texture(source_texture_1, UV);

    float animated_noise = noise(UV + vec2(TIME * time_speed, 0.0));
    float wave = sin(TIME * time_speed + animated_noise * 2.0) * 0.5 + 0.5;

    float gradient_factor = smoothstep(0.0, 1.0, dot(UV, normalize(gradient_direction)) * gradient_scale);
    vec4 gradient_color = mix(texture_color_1, source_color_2, gradient_factor);

    float pulsating_factor = mix(0.5, 1.5, wave);

    float alpha_factor = smoothstep(0.0, 1.0, dot(UV, normalize(gradient_direction)) * alpha_gradient_scale);

    // Edge falloff based on UV distance from center (existing)
    float edge_alpha = smoothstep(0.5, 0.0, length(UV - vec2(0.5)) * edge_falloff);

    // New edge falloff from all sides
    float dist_from_edges = min(UV.x, 1.0 - UV.x); // Distance to the left or right edge
    dist_from_edges = min(dist_from_edges, min(UV.y, 1.0 - UV.y)); // Distance to top or bottom edge

    // Apply the falloff effect from all sides
    float all_sides_edge_alpha = smoothstep(0.0, 1.0, dist_from_edges * edge_falloff_all_sides);

    EMISSION = gradient_color.rgb * emission_strength * pulsating_factor;
    ALBEDO = gradient_color.rgb;
    ALPHA = alpha_factor * edge_alpha * all_sides_edge_alpha; // Combined effect of both falloffs
}
