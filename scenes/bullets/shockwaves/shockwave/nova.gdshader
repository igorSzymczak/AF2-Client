shader_type canvas_item;

uniform float radius_inner: hint_range(0.0, 1.0) = 0.6;
uniform float radius_outer: hint_range(0.0, 1.0) = 0.8;

uniform float angle_from: hint_range(-1.0, 1.0) = -1.0;
uniform float angle_to: hint_range(-1.0, 1.0) = 1.0;

uniform float softness: hint_range(0.0, 0.1) = 0.036;

uniform float angle_smooth: hint_range(0.0, 1.0) = 1.0;

uniform float outer_to_inner: hint_range(0.0, 1.0) = 0.0;

uniform float alpha = 1.0;

float wrap_angle(float a) {
    if (a > 3.141592) a -= 6.283185;
    if (a < -3.141592) a += 6.283185;
    return a;
}

void fragment() {
	float ang1 = angle_from * 3.141592;
	float ang2 = angle_to   * 3.141592;

	vec2 p = UV * 2.0 - 1.0;
	float dist = length(p);
	float ang = atan(p.y, p.x);

	// fajny trick z multiplikatorem, zostawiam
	float smooth_ang_multiplier = sqrt(1.0 + angle_smooth);

	float fade_left  =  smoothstep(ang1, ang1 + angle_smooth, ang / smooth_ang_multiplier);
	float fade_right = 1.0 - smoothstep(ang2 - angle_smooth, ang2, ang / smooth_ang_multiplier);
	float angle_fade = fade_left * fade_right;

	float base_thickness = radius_outer - radius_inner;

	// *** KLUCZOWA ZMIANA – czubek na zewnętrznym okręgu ***
	float local_inner = radius_inner + (base_thickness * (1.0 - angle_fade)) * (1.0 - outer_to_inner);
	float local_outer = radius_outer - (base_thickness * (1.0 - angle_fade)) * outer_to_inner;

	if (dist < local_inner) discard;
	if (dist > local_outer) discard;

	float softness_alive = softness + abs(0.02 * sin(TIME * 4.0));

	float fade_inner = smoothstep(local_inner, local_inner + softness_alive, dist);
	float fade_outer = 1.0 - smoothstep(local_outer - softness_alive, radius_outer, dist);

	float radial_mask = fade_inner * fade_outer;
	float mask = radial_mask * angle_fade;

	if (mask <= 0.0) discard;

	COLOR = texture(TEXTURE, UV) * mask;
	COLOR.a *= alpha;
}
