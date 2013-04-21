uniform Image glowmap;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 src = Texel(glowmap, texture_coords);
	vec3 dst = Texel(texture, texture_coords).rgb;
	return vec4((src.rgb + dst) - (src.rgb * dst), src.a);
}
