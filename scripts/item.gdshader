shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness_boost : hint_range(1.0, 3.0) = 2.0;
uniform float desaturate_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    // Step 1: Brighten the original
    vec3 boosted = original.rgb * brightness_boost;
    boosted = clamp(boosted, 0.0, 1.0);

    // Step 2: Desaturate the brown (make it closer to gray/white)
    float gray = dot(boosted, vec3(0.299, 0.587, 0.114)); // standard grayscale
    boosted = mix(boosted, vec3(gray), desaturate_strength);

    // Step 3: Apply pastel or pink color
    COLOR = vec4(boosted * tint_color.rgb, original.a * tint_color.a);
}
