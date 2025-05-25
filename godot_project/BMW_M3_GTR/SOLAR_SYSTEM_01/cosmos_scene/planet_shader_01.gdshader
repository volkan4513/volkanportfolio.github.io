shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_burley, specular_schlick_ggx;

// Base color with alpha
uniform vec4 albedo_color : source_color; 
uniform sampler2D albedo_texture;
uniform bool use_albedo_texture = false;

// Highlight color with alpha
uniform vec4 highlight_color : source_color;
uniform float highlight_range : hint_range(0.0, 1.0);
uniform float highlight_alpha : hint_range(0.0, 1.0) = 1.0;

// Emission
uniform vec3 emission_color : source_color = vec3(0.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 0.0;

uniform float metallic;
uniform float roughness;
uniform float clearcoat;
uniform float clearcoat_roughness;
uniform float flake_intensity;
uniform sampler2D noise_texture;

void fragment() {
    vec3 view_dir = normalize(VIEW);

    // Get base color (texture or uniform)
    vec4 base_color = use_albedo_texture ? texture(albedo_texture, UV) : albedo_color;

    // Flake effect
    float flake = texture(noise_texture, UV * 10.0).r * flake_intensity;

    // Highlight effect
    float highlight_factor = pow(max(dot(NORMAL, view_dir), 0.0), highlight_range * 3.0);
    vec4 blended_color = mix(base_color, highlight_color, highlight_factor);

    // Final color output
    ALBEDO = blended_color.rgb + flake * 0.2;

    // Final alpha: blend between base and highlight alpha, then apply global highlight_alpha
    float base_alpha = base_color.a;
    float highlight_alpha_mix = mix(base_alpha, highlight_color.a, highlight_factor);
    ALPHA = mix(1.0, highlight_alpha_mix, highlight_alpha);

    // Emission
    EMISSION = emission_color * emission_strength;

    METALLIC = metallic;
    ROUGHNESS = roughness;
    CLEARCOAT = clearcoat;
    CLEARCOAT_ROUGHNESS = clearcoat_roughness;
}
