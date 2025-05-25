shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D frequency_tex; // 1D texture with frequency values
uniform int num_bars = 64;
uniform float radius = 1.0;
uniform float bar_height = 1.0;
uniform float time;

void vertex() {
    float angle = atan(VERTEX.x, VERTEX.z);
    if (angle < 0.0) angle += 6.283185; // Normalize to [0, 2π]

    int bar_index = int(floor(float(num_bars) * angle / 6.283185));
    float freq = texelFetch(frequency_tex, ivec2(bar_index, 0), 0).r;

    float current_radius = radius + freq * bar_height;
    float x = sin(angle) * current_radius;
    float z = cos(angle) * current_radius;

    VERTEX.x = x;
    VERTEX.z = z;
}

void fragment() {
    float alpha = 1.0;
    
    // Make areas outside bars transparent
    float dist = length(UV - vec2(0.5));
    if (dist > 0.52) {
        alpha = 0.0;
    }

    ALBEDO = vec3(0.2 + UV.x, 0.4 + UV.y, 0.9);
    ALPHA = alpha;
}
