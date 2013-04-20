const float sigma = 2.5;
const float blur_size = 1.0 / 300.0;
const float numBlurPixelsPerSide = 2.0;
uniform vec2 blurMultiplyVec;
const float pi = 3.14159;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
	vec3 incrementalGaussian;
	incrementalGaussian.x = 1.0 / (sqrt(2.0 * pi) * sigma);
	incrementalGaussian.y = exp(-0.5 / (sigma * sigma));
	incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;

	vec4 avgValue = vec4(0.0);
	float coefficientSum = 0.0;

	avgValue += Texel(texture, tex_coords) * incrementalGaussian.x;
	coefficientSum += incrementalGaussian.x;
	incrementalGaussian.xy *= incrementalGaussian.yz;

	for(float i = 1.0; i <= numBlurPixelsPerSide; i++) {
		avgValue += Texel(texture, tex_coords - i * blur_size * blurMultiplyVec) * incrementalGaussian.x;
		avgValue += Texel(texture, tex_coords + i * blur_size * blurMultiplyVec) * incrementalGaussian.x;
		coefficientSum += 2 * incrementalGaussian.x;
		incrementalGaussian.xy *= incrementalGaussian.yz;
	}

	color = avgValue / coefficientSum;
	return vec4(color.rgb, 1.0);
}
