//Generated with OpenAI Help, thank you!
shader_type canvas_item;

// Base gradient color (usually black)
uniform vec4 gradient_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// How opaque the very bottom is (0 = invisible, 1 = full color)
uniform float max_alpha : hint_range(0.0, 1.0) = 0.6;

// Height of the gradient, as fraction of screen height
uniform float height_fraction : hint_range(0.0, 1.0) = 0.4;

// Noise controls
uniform float noise_amount : hint_range(0.0, 0.5) = 0.08;
uniform float noise_scale  : hint_range(1.0, 200.0) = 40.0;

// Vignette controls (darken sides slightly)
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_exponent : hint_range(0.5, 4.0) = 2.0;

// Simple hash-based noise
float rand(vec2 co) {
    float n = dot(co, vec2(12.9898, 78.233));
    return fract(sin(n) * 43758.5453);
}

void fragment() {
    // UV.y: 0 = top, 1 = bottom
    float y = UV.y;

    // Bottom gradient
    float start = 1.0 - height_fraction;
    float t = smoothstep(start, 1.0, y);
    float base_alpha = max_alpha * t;

    // Vignette on left and right
    float dist_from_center_x = abs(UV.x - 0.5) * 2.0; // 0 at center, ~1 at edges
    float vignette = pow(clamp(dist_from_center_x, 0.0, 1.0), vignette_exponent);
    float vignette_factor = 1.0 + vignette_strength * vignette;

    // Noise (static or very subtle shimmering)
    float n = rand(UV * noise_scale);
    float noise_offset = (n - 0.5) * 2.0 * noise_amount; // range roughly [-noise_amount, +noise_amount]

    // Combine: base alpha, vignette, and noise (only where gradient exists)
    float final_alpha = base_alpha * vignette_factor + noise_offset * base_alpha;
    final_alpha = clamp(final_alpha, 0.0, 1.0);

    // Final color
    vec3 base_rgb = gradient_color.rgb;
    COLOR = vec4(base_rgb, final_alpha);
}
