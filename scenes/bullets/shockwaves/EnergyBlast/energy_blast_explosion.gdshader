shader_type canvas_item;

uniform float radius_outer: hint_range(0.0, 1.0) = 0.8;
uniform float radius_inner: hint_range(0.0, 1.0) = 0.6;

uniform float angle_from: hint_range(-1.0, 1.0) = -1.0;
uniform float angle_to: hint_range(-1.0, 1.0) = 1.0;

uniform float softness: hint_range(0.0, 0.5) = 0.03;
uniform float angle_smooth: hint_range(0.0, 1.0) = 0.5;
uniform float outer_to_inner: hint_range(0.0, 1.0) = 0.5;

uniform sampler2D noise_texture: repeat_enable;

uniform float alpha = 1.0;


uniform float wave_amp = 2.0;   // jak bardzo “wybija”
uniform float wave_freq = 1.0;  // ile ząbków na łuku
uniform float wave_speed = 5.0;  // jak szybko faluje

void vertex() {
    vec2 p = VERTEX.xy;
    float ang = atan(p.y, p.x);
    float dist = length(p);

    // falowanie po kącie (zygzak)
    float w = sin(ang * wave_freq + TIME * wave_speed);

    // przesuwamy tylko radialnie do przodu
    float offset = w * wave_amp;

    vec2 dir = normalize(p);
    p += dir * offset;

    VERTEX.xy = p;
}

// Prosty fraktalny szum 2D (3 oktawy)
float noise(vec2 uv) {
    float n = 0.0;
    float scale = 1.0;
    float amplitude = 1.0;
    for(int i=0; i<3; i++){
        n += amplitude * fract(sin(dot(uv * scale ,vec2(12.9898,78.233))) * 43758.5453);
        scale *= 2.0;
        amplitude *= 0.5;
    }
    return n;
}

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

    float smooth_ang_multiplier = sqrt(1.0 + angle_smooth);
    float fade_left  =  smoothstep(ang1, ang1 + angle_smooth, ang / smooth_ang_multiplier);
    float fade_right = 1.0 - smoothstep(ang2 - angle_smooth, ang2, ang / smooth_ang_multiplier);
    float angle_fade = fade_left * fade_right;

    float base_thickness = radius_outer - radius_inner;
    float local_inner = radius_inner + (base_thickness * (1.0 - angle_fade)) * (1.0 - outer_to_inner);
    float local_outer = radius_outer - (base_thickness * (1.0 - angle_fade)) * outer_to_inner;

    if (dist < local_inner) discard;
    if (dist > local_outer) discard;

    float fade_inner = smoothstep(local_inner, local_inner + softness, dist);
    float fade_outer = 1.0 - smoothstep(local_outer - softness, radius_outer, dist);

    float radial_mask = fade_inner * fade_outer;
    float mask = radial_mask * angle_fade;
    if (mask <= 0.0) discard;

    // --- szum dla ognia/chmur ---
    float n = noise(vec2(ang * 3.0, dist * 100.0 + TIME * 0.5));
    float alpha_noise = mix(100.0, 0.1, n); // większe plamy przezroczystości
    //COLOR = vec4(fiery, alpha_noise) * mask;
	
	vec2 uv_update = vec2(UV.x + sin(TIME * 1.0) * 0.3, UV.y + cos(TIME * 1.0) * 0.3);
	COLOR = texture(noise_texture, uv_update) * mask;
	COLOR.a *= alpha;
}
