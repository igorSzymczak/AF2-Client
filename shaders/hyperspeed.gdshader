shader_type canvas_item;

uniform bool enabled = true;

/* KOLORY */
uniform vec3 color_a : source_color = vec3(0.4, 0.8, 1.0);
uniform vec3 color_b : source_color = vec3(1.0, 0.6, 0.2);

/* WYGLĄD */
uniform float brightness : hint_range(0.1, 5.0) = 1.0;
uniform float streak_length : hint_range(0.01, 0.1) = 0.025;
uniform float artifact_density : hint_range(0.01, 0.2) = 0.06;

/* FRAKTAL */
uniform int fractal_iterations = 10;
uniform int ray_steps = 100;

/* ANIMACJA */
uniform float speed = 1.0;
uniform float swirl = 1.0;

void fragment() {

	if (!enabled) {
		COLOR = COLOR;
	}
	else {
		float s = 0.0;
		float v = 0.0;

		vec2 ires = 1.0 / SCREEN_PIXEL_SIZE;
		vec2 uv = (FRAGCOORD.xy / ires) * 2.0 - 1.0;

		float itime = (TIME - 2.0) * 58.0 * speed;

		vec3 col = vec3(0.0);

		vec3 init = vec3(
			sin(itime * .0032 * swirl) * .3,
			.35 - cos(itime * .005 * swirl) * .3,
			itime * 0.002
		);

		for (int r = 0; r < 200; r++) {

			if (r >= ray_steps) break;

			vec3 p = init + s * vec3(uv, 0.05);
			p.z = fract(p.z);

			for (int i = 0; i < 20; i++) {

				if (i >= fractal_iterations) break;
				p = abs(p * 2.04) / dot(p, p) - .9;
			}

			v += pow(dot(p, p), .7) * artifact_density;

			vec3 gradient = mix(color_a, color_b, v);

			col += gradient * v * 0.00003 * brightness;

			s += streak_length;
		}

		COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
	}
}