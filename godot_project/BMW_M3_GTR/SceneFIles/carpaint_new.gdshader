shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 albedo_color : source_color; // Base color
uniform vec3 highlight_color : source_color; // Highlight color
uniform float highlight_range : hint_range(0.0, 1.0); // Controls intensity of highlight
uniform float metallic;
uniform float roughness;
uniform float clearcoat;
uniform float clearcoat_roughness;
uniform float flake_intensity;
uniform sampler2D noise_texture;

void fragment() {
    vec3 normal_map = NORMAL * 2.0 - 1.0;
    vec3 view_dir = normalize(VIEW);

    // Flake effect using provided noise texture
    float flake = texture(noise_texture, UV * 10.0).r * flake_intensity;

    // Highlight effect based on viewing angle with adjustable range
    float highlight_factor = pow(max(dot(NORMAL, view_dir), 0.0), highlight_range * 3.0);
    vec3 blended_color = mix(albedo_color, highlight_color, highlight_factor);

    // Apply PBR shading
    ALBEDO = blended_color + flake * 0.2;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    CLEARCOAT = clearcoat;
    CLEARCOAT_ROUGHNESS = clearcoat_roughness;
}
