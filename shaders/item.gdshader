shader_type canvas_item;

// the only two uniforms you actually need
uniform vec4 tint_color;
uniform float brightness_boost = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
    // base.r is your grayscale mask (0 = full shadow, 1 = full highlight)
	float mask = clamp(base.r * brightness_boost, 0.0, 1.0);
    // multiply your pastel tint by that mask
	vec3 shaded = tint_color.rgb * mask;
    // preserve sprite alpha * tint alpha
	COLOR = vec4(shaded, base.a * tint_color.a);
}
