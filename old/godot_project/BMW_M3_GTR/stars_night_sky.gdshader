shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 inner_color : source_color = vec4(0.1, 0.4, 0.9, 1.0);
uniform vec4 outer_color : source_color = vec4(0.01, 0.02, 0.08, 1.0);
uniform float color_blend : hint_range(0.0, 1.0) = 0.85;

uniform float noise_scale = 6.0;
uniform float noise_strength = 0.5;

uniform int star_density = 300;
uniform float star_size = 0.002;
uniform float flicker_speed = 2.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(rand(i + vec2(0.0, 0.0)), rand(i + vec2(1.0, 0.0)), u.x),
        mix(rand(i + vec2(0.0, 1.0)), rand(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

float star_field(vec2 uv, float t) {
    float result = 0.0;
    for (int i = 0; i < star_density; i++) {
        vec2 seed = vec2(float(i), float(i * 13));
        vec2 pos = fract(vec2(rand(seed), rand(seed + 1.0)));
        float dist = length(uv - pos);
        float flicker = 0.5 + 0.5 * sin(t * flicker_speed + float(i));
        result += smoothstep(star_size, 0.0, dist) * flicker;
    }
    return clamp(result, 0.0, 1.0);
}

void fragment() {
    vec2 uv = UV;
    float t = TIME;

    // Galaxy noise
    vec2 centered_uv = uv * 2.0 - 1.0;
    float radius = length(centered_uv);
    float n = noise(uv * noise_scale + vec2(t * 0.01, t * 0.01));
    float blend = clamp(radius + n * noise_strength, 0.0, 1.0);

    vec4 galaxy_color = mix(inner_color, outer_color, blend * color_blend);

    // Stars
    float stars = star_field(uv, t);

    vec3 color = galaxy_color.rgb + vec3(stars);
    float alpha = max(galaxy_color.a, stars);

    ALBEDO = color;
    EMISSION = color * 2.5;
    ALPHA = alpha;
}
