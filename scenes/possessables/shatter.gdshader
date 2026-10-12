shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float seed = 0.0;
uniform ivec2 grid = ivec2(3, 5);
uniform float crumble = 0.95;
uniform float spread = 0.22;
uniform float bottom_pad = 8.0;
uniform float side_pad = 16.0;
uniform vec2 region_pos = vec2(135.0, 268.0);
uniform vec2 region_size = vec2(12.0, 17.0);

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031 + seed);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void vertex() {
	VERTEX.x += sign(VERTEX.x) * side_pad;
	if (VERTEX.y > 0.0) {
		VERTEX.y += bottom_pad;
	}
}

void fragment() {
	vec2 uv_01 = (UV / TEXTURE_PIXEL_SIZE - region_pos) / region_size;
	vec2 dest;
	dest.x = (uv_01.x - 0.5) * (region_size.x + 2.0 * side_pad) / region_size.x + 0.5;
	dest.y = uv_01.y * (region_size.y + bottom_pad) / region_size.y;

	vec2 grid_f = vec2(grid);
	vec2 start = floor(clamp(dest, vec2(0.001), vec2(0.999)) * grid_f);
	vec4 best = vec4(0.0);
	float best_w = 1.0e9;

	for (int y = -8; y <= 1; y++) {
		for (int x = -3; x <= 3; x++) {
			vec2 guess = start + vec2(float(x), float(y));
			if (guess.x < 0.0 || guess.y < 0.0 || guess.x >= grid_f.x || guess.y >= grid_f.y) {
				continue;
			}

			float h = hash12(guess);
			float top = 1.0 - (guess.y + 0.5) / grid_f.y;
			vec2 off = vec2(
				(hash12(guess + 9.1) * 2.0 - 1.0) * spread,
				top * crumble * mix(0.55, 1.0, h)
			) * progress;
			off = floor(off * region_size + 0.5) / region_size;

			vec2 orig = dest - off;
			if (any(notEqual(floor(orig * grid_f), guess))) {
				continue;
			}
			if (orig.x < 0.0 || orig.y < 0.0 || orig.x > 1.0 || orig.y > 1.0) {
				continue;
			}

			orig = (floor(orig * region_size) + 0.5) / region_size;
			vec4 tex = texture(TEXTURE, (region_pos + orig * region_size) * TEXTURE_PIXEL_SIZE);
			if (tex.a < 0.01) {
				continue;
			}

			float w = length(orig - (guess + 0.5) / grid_f);
			if (w < best_w) {
				best_w = w;
				best = tex;
			}
		}
	}

	if (best.a < 0.01) {
		discard;
	}
	COLOR = best * COLOR;
}