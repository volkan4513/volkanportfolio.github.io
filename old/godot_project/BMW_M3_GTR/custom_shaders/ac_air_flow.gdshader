shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

// Wave properties
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.2;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec2 wave_direction = vec2(1.0, 0.0);

// Noise properties for turbulence
uniform float noise_strength : hint_range(0.0, 1.0) = 0.3;
uniform float noise_scale : hint_range(0.1, 5.0) = 2.0;
uniform float noise_speed : hint_range(0.0, 5.0) = 1.0;

// Heatwave distortion properties
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.2;
uniform float distortion_speed : hint_range(0.0, 5.0) = 1.5;

// Wave start controls
uniform float wave_start_x : hint_range(-5.0, 5.0) = 0.0;
uniform float wave_start_y : hint_range(-5.0, 5.0) = 0.0;

// Gradient properties
uniform vec4 color_start = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 color_middle = vec4(1.0, 1.0, 1.0, 0.3);
uniform vec4 color_end = vec4(1.0, 1.0, 1.0, 0.5);
uniform float gradient_angle : hint_range(0.0, 360.0) = 0.0; // Rotation angle in degrees
uniform float gradient_start : hint_range(0.0, 1.0) = 0.2;
uniform float gradient_middle : hint_range(0.0, 1.0) = 0.5;
uniform float gradient_end : hint_range(0.0, 1.0) = 0.8;

// Noise intensity and speed control
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.5;

// Simple Perlin-like noise function
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float smooth_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex() {
    vec2 dir = normalize(wave_direction);
    float pos_offset = dot(VERTEX.xz, dir);

    if (VERTEX.x >= wave_start_x && VERTEX.y >= wave_start_y) {
        float radial_effect = length(VERTEX.xz - vec2(wave_start_x, wave_start_y)) * 0.5;
        float wave = sin(pos_offset * wave_frequency + TIME * wave_speed) * cos(radial_effect);
        
        // Use smooth noise for more organic turbulence
        float turbulence = smooth_noise(VERTEX.xz * noise_scale + vec2(TIME * noise_speed)) * noise_strength * noise_intensity;
        
        VERTEX.y += (wave + turbulence) * wave_amplitude;
    }
}

void fragment() {
    vec2 distortion_uv = UV;
    distortion_uv.x += sin(UV.y * wave_frequency + TIME * distortion_speed) * distortion_strength;
    distortion_uv.y += cos(UV.x * wave_frequency + TIME * distortion_speed) * distortion_strength;

    // Compute gradient direction using rotation
    float angle_rad = radians(gradient_angle);
    mat2 rotation_matrix = mat2(vec2(cos(angle_rad), -sin(angle_rad)), vec2(sin(angle_rad), cos(angle_rad)));
    vec2 rotated_uv = rotation_matrix * (distortion_uv - vec2(0.5)) + vec2(0.5);

    // Compute gradient factor based on rotated UV and adjustable fade range
    float gradient_factor = rotated_uv.y;
    vec4 gradient_color;
    if (gradient_factor < gradient_middle) {
        gradient_color = mix(color_start, color_middle, smoothstep(gradient_start, gradient_middle, gradient_factor));
    } else {
        gradient_color = mix(color_middle, color_end, smoothstep(gradient_middle, gradient_end, gradient_factor));
    }

    ALBEDO = gradient_color.rgb;
    ALPHA = gradient_color.a;
}
