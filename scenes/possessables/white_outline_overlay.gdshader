shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float outline_size = 1.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * outline_size;
    
    float outline = texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    outline += texture(TEXTURE, UV - vec2(size.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    outline += texture(TEXTURE, UV - vec2(0.0, size.y)).a;
    
    outline = min(outline, 1.0);
    
    vec4 current_pixel = texture(TEXTURE, UV);
    
    float alpha_mask = max(0.0, outline - current_pixel.a);
    
    COLOR = mix(vec4(0.0), outline_color, alpha_mask);
}