shader_type canvas_item;

uniform vec4 bg_color: source_color;
uniform vec2 offset;
uniform float zoom = 1.0; // 1.0 = normalnie, >1 przybliża, <1 oddala
uniform float smallStarSlow = 8.0;

uniform float smallStarAmount = 0.002;

uniform int layer_count = 3;
uniform int max_layers = 8;
uniform float base_cell_size = 120.0;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 center = screen_size * 0.5;

	vec2 uv = (FRAGCOORD.xy - center) * zoom + center;

	vec2 normCoordSmall = uv + floor(offset / smallStarSlow);
	
	float color = 0.0;

	for (int i = 0; i < 8; i++)
	{
	if (i >= layer_count) break;
	
	float depth = float(i) / float(layer_count - 1); // 0 = blisko, 1 = daleko
	
	// im dalej, tym mniejsze i wolniejsze
	float layer_scale = mix(1.5, 0.5, depth);
	float cell_size = base_cell_size * mix(0.7, 2.0, depth);
	float parallax = mix(1.0, 0.8, depth);
	
	vec2 layer_coord = uv * layer_scale + offset / parallax / smallStarSlow;
	
	vec2 cell = floor(layer_coord / cell_size);
	float star_mask = rand(cell + float(i) * 13.37);
	
	if (star_mask > 1.0 - smallStarAmount)
		{
			vec2 local_pos = fract(layer_coord / cell_size);
			vec2 star_offset = vec2(
			rand(cell + 1.23 + float(i)),
			rand(cell + 4.56 + float(i))
		);
		
		float d = distance(local_pos, star_offset);
		
		float phase = rand(cell + 7.89 + float(i));
		float twinkle = 0.85 * sin(TIME * (2.0 + phase * 5.0) + phase * 20.0) + 0.95;
		
		float size = mix(0.1, 0.03, depth);
		float star = smoothstep(size, 0.0, d);
		
		color += star * twinkle;
		}
	}
	COLOR = vec4(vec3(color),color) + bg_color;
}