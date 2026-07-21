shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_size = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float outline = 0.0;

    outline += texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x * outline_size, 0.0)).a;
    outline += texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x * outline_size, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y * outline_size)).a;
    outline += texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y * outline_size)).a;

    outline = clamp(outline, 0.0, 1.0);

    if (tex.a == 0.0 && outline > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = tex;
    }
}