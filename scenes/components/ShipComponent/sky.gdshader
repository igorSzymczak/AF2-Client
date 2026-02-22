shader_type canvas_item;

uniform vec4 bg_color: source_color;
uniform vec2 offset;
uniform float zoom = 1.0; // 1.0 = normalnie, >1 przybliża, <1 oddala
uniform float smallStarSlow = 8.0;

uniform float smallStarAmount = 0.002;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 center = screen_size * 0.5;

	vec2 uv = (FRAGCOORD.xy - center) / zoom + center;

	vec2 normCoordSmall = uv + floor(offset / smallStarSlow);
	
	float color = 0.0;
	
	// Draw Small stars
	vec2 cell = floor(normCoordSmall / 20.0);

// decyzja czy gwiazda istnieje
float star_mask = rand(cell);

if (star_mask > 1.0 - smallStarAmount)
{
    // losowa pozycja w komórce
    vec2 local_pos = fract(normCoordSmall / 20.0);
    vec2 star_offset = vec2(rand(cell + 1.23), rand(cell + 4.56));
    
    float d = distance(local_pos, star_offset);

    // niezależna faza migania
    float phase = rand(cell + 7.89);
    float twinkle = 0.85 * sin(TIME * (2.0 + phase * 5.0) + phase * 20.0) + 0.95;

    float star = smoothstep(0.05, 0.0, d);

    color = star * twinkle;
}
	COLOR = vec4(vec3(color),color) + bg_color;
}