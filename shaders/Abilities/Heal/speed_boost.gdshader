shader_type canvas_item;

uniform float dir_x: hint_range(-1.0, 1.0) = 0.0;
uniform float dir_y: hint_range(-1.0, 1.0) = 0.015;

uniform float stretch = 1.0;
uniform float blur_strength = 1.0;
uniform int samples = 2;
uniform float glow_strength = 0.3;

uniform sampler2D gradient: repeat_enable;
uniform float margin : hint_range(-0.2, 0.45) = 0.15;


void vertex() {
	vec2 dir = vec2(dir_x, dir_y);
	VERTEX += dir * VERTEX.y * stretch;
	VERTEX *= (1.0 + margin * 2.0);
}

void fragment() {
	vec2 dir = vec2(dir_x, dir_y);
	vec2 ndir = normalize(dir);

	// UV zmniejszone o margines
	vec2 uv_base = UV * (1.0 - 2.0 * margin) + vec2(margin);

	vec4 sum = vec4(0.0);

	// --- 1) SMUŻENIE DO TYŁU ---
	for (int i = 0; i < samples; i++) {
		float t = float(i) / float(samples - 1);
		vec2 off = -ndir * t * blur_strength * 0.1;

		vec2 uv_s = clamp(uv_base + off, vec2(0.0), vec2(1.0));

		vec4 base = texture(TEXTURE, uv_s);
		vec4 glow = texture(gradient, vec2(t, 0.5));
		base.rgb = mix(base.rgb, glow.rgb, glow_strength * t);

		sum += base;
	}

	// --- 2) SMUŻENIE DO PRZODU ---
	for (int i = 0; i < samples; i++) {
		float t = float(i) / float(samples - 1);
		vec2 off = ndir * t * blur_strength * 0.1;

		vec2 uv_s = clamp(uv_base + off, vec2(0.0), vec2(1.0));

		vec4 base = texture(TEXTURE, uv_s);
		vec4 glow = texture(gradient, vec2(t, 0.5));
		base.rgb = mix(base.rgb, glow.rgb, glow_strength * t);

		sum += base;
	}

	// Średnia z dwóch kierunków
	COLOR = sum / float(samples * 2);
}
