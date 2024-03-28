shader_type canvas_item;

uniform float scale: hint_range(-1, 1) = 0.1;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//uniform sampler2D distortionTexture;
//uniform vec2 scroll = vec2(0.1 , 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	//vec2 distortedUV = UV;
	//distortedUV.x -= distortedUV.y * scale;
	//vec4 pixelColor = texture(TEXTURE, distortedUV);
	//
	//vec4 screenColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	//COLOR = screenColor;
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE, UV).a * scale;
	vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
