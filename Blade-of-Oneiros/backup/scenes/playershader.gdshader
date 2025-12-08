shader_type canvas_item;

uniform float cut : hint_range(0.0, 1.0) = 0.0;     // 0 = fully visible, 1 = fully gone (bottom-up)
uniform float softness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    float threshold = 1.0 - cut; 
    float t = smoothstep(threshold - softness, threshold + softness, UV.y);

    col.a *= 1.0 - t;

    COLOR = col;
}
