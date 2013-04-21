uniform Image glowmap;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 src = Texel(glowmap, texture_coords);
	vec4 dst = Texel(texture, texture_coords);
	return (src + dst) - (src * dst);
}
