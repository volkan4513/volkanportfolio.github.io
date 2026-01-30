shader_type spatial;

uniform sampler2D source_texture_1;
uniform vec4 source_color_1 : source_color;
uniform float emission_strength;

void fragment() {
    vec4 texture_color_1 = texture(source_texture_1, UV);
    float wave = sin(TIME * 2.0) * 0.5 + 0.5;
    vec4 final_color = mix(texture_color_1, source_color_1, 0.5);
    final_color.rgb *= wave; // Apply the pulsating effect to the color
    float texture_alpha = texture_color_1.a;

    EMISSION = final_color.rgb * emission_strength;
    ALBEDO = final_color.rgb;
    ALPHA = texture_alpha; // Directly using texture's alpha for transparency
}
