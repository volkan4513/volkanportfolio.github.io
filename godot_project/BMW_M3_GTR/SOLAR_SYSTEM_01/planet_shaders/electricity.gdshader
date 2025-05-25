shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

uniform float speed = 0.3;
uniform float amplitude = 0.3; // Controls motion and visual turbulence

uniform vec2 flow_direction = vec2(1.0, 0.0);
uniform float flow_scale = 1.5;

uniform float curl_frequency = 2.5;
uniform float curl_strength = 0.6;

uniform float detail_scale = 1.2;

uniform vec4 color_start : source_color = vec4(0.8, 0.1, 0.1, 1.0);
uniform vec4 color_middle : source_color = vec4(1.0, 0.3, 0.2, 1.0);
uniform vec4 color_end : source_color = vec4(1.0, 0.8, 0.7, 1.0);

uniform float middle_blend_start : hint_range(0.0, 1.0) = 0.3;
uniform float middle_blend_end : hint_range(0.0, 1.0) = 0.65;
uniform float gradient_power = 2.0;
uniform bool use_middle_blend = false;

// 2D hash noise
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Simple FBM (Fractal Brownian Motion) noise
float fbm(vec2 p) {
	float total = 0.0;
	float freq = 1.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		total += noise(p * freq) * amp;
		freq *= 2.0;
		amp *= 0.5;
	}
	return total;
}

// Vertex distortion
void vertex() {
	vec2 flow_uv = VERTEX.xz * flow_scale + TIME * speed;
	float swirl = sin(dot(flow_uv, vec2(curl_frequency, curl_frequency * 1.2)));
	float curl_noise = noise(flow_uv + swirl);
	float displace = curl_noise * 2.0 - 1.0;

	VERTEX.y += displace * amplitude * curl_strength;
}

// Gradient coloring
vec3 gradient_color(float t) {
	t = clamp(t, 0.0, 1.0);
	t = pow(t, gradient_power);

	if (!use_middle_blend) {
		return mix(color_start.rgb, color_end.rgb, t);
	}

	vec3 col1 = mix(color_start.rgb, color_middle.rgb, smoothstep(0.0, middle_blend_start, t));
	vec3 col2 = mix(color_middle.rgb, color_end.rgb, smoothstep(middle_blend_end, 1.0, t));
	return mix(col1, col2, smoothstep(middle_blend_start, middle_blend_end, t));
}

// Final fragment shading
void fragment() {
	vec2 uv = UV * detail_scale;
	float flow_pos = dot(UV, normalize(flow_direction));

	// Dynamic noise
	float n1 = fbm(uv + TIME * speed * 0.2 * amplitude);
	float n2 = noise(uv * 0.5 + TIME * 0.1 * amplitude);
	float n = mix(n1, n2, 0.5);

	vec3 col = gradient_color(flow_pos);

	// Soft glow flicker without alpha cutoff
	float flicker = 0.95 + 0.05 * sin(TIME * 2.0 * amplitude);
	float glow = mix(0.6, 1.0, n); // Soft dynamic texture

	ALBEDO = col * glow * flicker;
	ALPHA = 1.0; // Fully visible always
}
