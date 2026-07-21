shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 0.0;
uniform float softness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 uv = UV;
    
    // Correctly calculate the screen's aspect ratio (Width / Height)
    float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    
    // Adjust the X axis based on that ratio to make the circle perfectly uniform
    uv.x = (uv.x - center.x) * aspect_ratio + center.x;
    
    float dist = distance(uv, center);
    float circle = smoothstep(radius, radius - softness, dist);
    
    COLOR.a = circle;
}