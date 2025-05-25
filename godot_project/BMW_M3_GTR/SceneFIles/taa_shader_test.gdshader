shader_type spatial;

uniform sampler2D current_frame;  // Current frame texture
uniform sampler2D previous_frame; // Previous frame texture
uniform sampler2D velocity_buffer : hint_normal; // Velocity buffer (motion vectors)

uniform vec2 texel_size;      // Size of a texel in screen space (1.0 / screen size)
uniform vec2 jitter_offset;      // Jitter offset for current frame
uniform float blend_factor : hint_range(0.0, 1.0); // Blend factor between current and previous frame
uniform vec2 viewport_size; // The size of the viewport (passed as a uniform)

void fragment() {
    // Calculate screen coordinates for the current fragment
    vec2 screen_coord = FRAGCOORD.xy / viewport_size;

    // Apply jitter offset to current frame sampling coordinates
    vec2 jittered_coord = screen_coord + jitter_offset * texel_size;

    // Sample the current frame with jittered coordinates
    vec4 current_color = texture(current_frame, jittered_coord);

    // Sample the velocity buffer to get motion vectors (velocity in screen space)
    vec2 velocity = texture(velocity_buffer, screen_coord).xy;

    // Reproject the previous frame using the velocity data (motion vector)
    vec2 previous_coord = screen_coord + velocity * texel_size;

    // Sample the previous frame at the reprojected coordinates
    vec4 previous_color = texture(previous_frame, previous_coord);

    // Apply Temporal Anti-Aliasing by blending the current and previous frames
    vec4 blended_color = mix(previous_color, current_color, blend_factor);

    // Output the final color (RGB components)
    ALBEDO = blended_color.rgb; // Extract RGB from vec4
}