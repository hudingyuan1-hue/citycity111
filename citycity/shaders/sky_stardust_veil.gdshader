shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec4 tint : source_color = vec4(0.28, 0.44, 1.0, 0.2);
uniform vec4 star_color : source_color = vec4(0.74, 0.88, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.22;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float drift : hint_range(0.0, 1.0) = 0.45;
uniform float seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(234.21, 91.77));
	p += dot(p, p + 19.19 + seed * 0.017);
	return fract(p.x * p.y);
}

float soft_noise(vec2 uv) {
	vec2 cell = floor(uv);
	vec2 local = fract(uv);
	float a = hash21(cell);
	float b = hash21(cell + vec2(1.0, 0.0));
	float c = hash21(cell + vec2(0.0, 1.0));
	float d = hash21(cell + vec2(1.0, 1.0));
	vec2 f = local * local * (3.0 - 2.0 * local);
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
	vec2 uv = UV;
	vec2 flow_uv = uv * vec2(4.0, 2.2) + vec2(TIME * 0.025 * drift, -TIME * 0.018 * drift + seed * 0.01);
	float cloud = soft_noise(flow_uv);
	float cloud_band = smoothstep(0.28, 0.88, cloud);

	vec2 star_uv = uv * (18.0 + mod(abs(seed), 9.0)) + vec2(TIME * 0.018, TIME * 0.010);
	vec2 star_cell = floor(star_uv);
	vec2 star_local = fract(star_uv);
	float star_seed = step(0.965, hash21(star_cell));
	float star_core = 1.0 - smoothstep(0.0, 0.20, length(star_local - vec2(0.5)));
	float star = star_seed * star_core;

	float vertical_fade = smoothstep(0.0, 0.18, uv.y) * smoothstep(1.0, 0.72, uv.y);
	float final_alpha = alpha * tint.a * vertical_fade * (0.28 + cloud_band * 0.72 + star * 1.4) * intensity;
	ALBEDO = mix(tint.rgb, star_color.rgb, clamp(star * 0.9, 0.0, 1.0));
	EMISSION = tint.rgb * cloud_band * 0.08 * intensity + star_color.rgb * star * 0.85 * intensity;
	ALPHA = clamp(final_alpha, 0.0, 0.82);
}
