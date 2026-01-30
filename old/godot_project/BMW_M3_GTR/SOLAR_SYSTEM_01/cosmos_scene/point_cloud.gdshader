shader_type spatial;
render_mode unshaded;

uniform float time;

void vertex() {
    // Convert spherical coords
    float r = 1.0;
    float theta = UV.x * 6.2831; // 0 - 2PI
    float phi = UV.y * 3.1415;   // 0 - PI

    vec3 pos = vec3(
        r * sin(phi) * cos(theta),
        r * cos(phi),
        r * sin(phi) * sin(theta)
    );

    // Animate with noise or wave
    float displacement = 0.1 * sin(time + UV.x * 10.0 + UV.y * 10.0);
    VERTEX = pos + normalize(pos) * displacement;
}
