uniform float time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	return floor(sin(time * 2.0 * 3.14 * 8.0) + 0.8) * vec4(1.0);
}
