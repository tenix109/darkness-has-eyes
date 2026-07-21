shader_type canvas_item;

uniform int pixel_size : hint_range(1, 16) = 4;
uniform int color_depth : hint_range(2, 32) = 8;

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 f_pixel_size = vec2(float(pixel_size));
	vec2 uv = floor(UV * size / f_pixel_size) * f_pixel_size / size;
	
	vec4 color = texture(TEXTURE, uv);
	
	float f_color_depth = float(color_depth);
	color.rgb = floor(color.rgb * f_color_depth) / f_color_depth;
	
	COLOR = color;
}