shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = vec4(0.0);
	float total_weight = 0.0;
	
	for (float x = -2.0; x <= 2.0; x += 1.0) {
		for (float y = -2.0; y <= 2.0; y += 1.0) {
			vec2 offset = vec2(x, y) * blur_amount * SCREEN_PIXEL_SIZE;
			float weight = 1.0 / (1.0 + dot(offset, offset));
			color += texture(screen_texture, SCREEN_UV + offset) * weight;
			total_weight += weight;
		}
	}
	
	COLOR = color / total_weight;
}