shader_type spatial;
render_mode unshaded, depth_draw_always, cull_back;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Color of the lines
uniform float line_spacing = 3;    // Distance between lines
uniform float line_thickness = 0.2;  // Thickness of each line (set as a fraction, e.g. 0.1 for a narrow line)
uniform float time = 0.0;            // Animation time
uniform mat3 inv_rot;              // Inverse rotation matrix (set from GDScript)
uniform int direction = 0;         // 0 for X, 1 for Y, 2 for Z

varying float de_rotated_coord;

void vertex() {
    // Remove the object's rotation so that the coordinate remains consistent
    vec3 adjusted = inv_rot * VERTEX;
    if (direction == 0) {
        de_rotated_coord = adjusted.x;
    } else if (direction == 1) {
        de_rotated_coord = adjusted.y;
    } else {
        de_rotated_coord = adjusted.z;
    }
}

void fragment() {
    // Create a repeating pattern along the chosen axis.
    // Adding 'time' causes the pattern to move along the selected axis.
    float pattern = fract((de_rotated_coord + time) / line_spacing);

    // We want the line to appear at the center of each repetition.
    // Compute the distance from the center (0.5) of the pattern.
    float dist = abs(pattern - 0.5);

    // Use smoothstep to generate a soft, narrow band.
    // When dist is near 0 the alpha is high; when dist > line_thickness it goes to 0.
    float alpha = 1.0 - smoothstep(0.0, line_thickness, dist);

    ALBEDO = line_color.rgb;
    ALPHA = alpha * line_color.a;
}
