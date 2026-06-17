shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 tint : source_color = vec4(0.44, 0.58, 0.76, 0.20);
uniform float alpha : hint_range(0.0, 1.0) = 0.20;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float mist_drift : hint_range(0.0, 1.0) = 0.45;
uniform float seed = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p + seed, vec2(59.3, 307.1))) * 29211.73);
}

float mist_noise(vec2 uv) {
	vec2 uv1 = uv + vec2(TIME * 0.020, TIME * 0.010) * mist_drift;
	vec2 uv2 = uv - vec2(TIME * 0.013, TIME * 0.017) * mist_drift;
	float n1 = hash21(floor(uv1 * vec2(18.0, 7.0)));
	float n2 = hash21(floor(uv2 * vec2(7.0, 4.0)));
	return n1 * 0.58 + n2 * 0.42;
}

void fragment() {
	float n = mist_noise(UV);
	float vertical = smoothstep(0.0, 0.18, UV.y) * smoothstep(1.0, 0.62, UV.y);
	float edge = smoothstep(0.0, 0.10, UV.x) * smoothstep(1.0, 0.90, UV.x);
	float pulse = 0.55 + 0.45 * sin(TIME * 0.32 + seed + UV.x * 7.0);
	float fog = smoothstep(0.28, 0.92, n) * vertical * edge * pulse;
	ALBEDO = tint.rgb;
	EMISSION = tint.rgb * (0.18 + fog * intensity);
	ALPHA = alpha * (0.10 + fog * 0.90);
}
