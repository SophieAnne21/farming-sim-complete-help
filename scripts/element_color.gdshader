shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.88, 0.79, 1.0); // Example pastel color

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	COLOR = vec4(tint_color.rgb, original.a * tint_color.a);
