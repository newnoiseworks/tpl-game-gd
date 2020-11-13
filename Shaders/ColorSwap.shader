shader_type canvas_item;

uniform vec3 skinColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 skinChangeColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 hairColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 hairChangeColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 primaryColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 primaryChangeColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 secondaryColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 secondaryChangeColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 tertiaryColor = vec3(-1.0, -1.0, -1.0);
uniform vec3 tertiaryChangeColor = vec3(-1.0, -1.0, -1.0);

bool shouldSwapColors(vec3 targetColor, vec3 changeColor, vec4 currColor) {
	vec3 neg = vec3(-1.0, -1.0, -1.0);
	float targetThreshold = .42;
	
	if (targetColor == neg || changeColor == neg) {
		return false;
	}
	
	vec3 targetPercentages = targetColor / 255.0;
	vec3 changePercentages = changeColor / 255.0;
	
	return (abs(currColor.r - targetPercentages.r) < targetThreshold &&	
		   abs(currColor.g - targetPercentages.g) < targetThreshold &&	
		   abs(currColor.b - targetPercentages.b) < targetThreshold) &&
			 currColor.a == 1.0;
}

vec4 swapColors(vec3 targetColor, vec3 changeColor, vec4 currColor) {
	vec3 targetPercentages = targetColor / 255.0;
	vec3 changePercentages = changeColor / 255.0;

	return vec4((changePercentages + (currColor.rgb - targetPercentages)), 1);
}

void fragment() {
	vec4 currColor = texture(TEXTURE, UV);
	
	if (shouldSwapColors(primaryColor, primaryChangeColor, currColor)) {
		COLOR = swapColors(primaryColor, primaryChangeColor, currColor);
	} else if (shouldSwapColors(secondaryColor, secondaryChangeColor, currColor)) {
		COLOR = swapColors(secondaryColor, secondaryChangeColor, currColor);
	} else if (shouldSwapColors(tertiaryColor, tertiaryChangeColor, currColor)) {
		COLOR = swapColors(tertiaryColor, tertiaryChangeColor, currColor);
	} else if (shouldSwapColors(hairColor, hairChangeColor, currColor)) {
		COLOR = swapColors(hairColor, hairChangeColor, currColor);
	} else if (shouldSwapColors(skinColor, skinChangeColor, currColor)) {
		COLOR = swapColors(skinColor, skinChangeColor, currColor);
	} else {
		COLOR = currColor;
	}
}
