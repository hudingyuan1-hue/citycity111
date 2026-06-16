shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 ink_color : source_color = vec4(0.05, 0.05, 0.045, 0.32);
uniform vec4 glow_color : source_color = vec4(0.35, 0.62, 1.0, 0.26);
uniform float alpha = 0.28;
uniform float intensity = 1.0;
uniform float seed = 1.0;
uniform float drift_speed = 0.08;
uniform float symbol_scale = 13.0;
uniform float failure = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 31.17) * 43758.5453123);
}

float glyph(vec2 uv) {
	vec2 cell = floor(uv * symbol_scale);
	vec2 f = fract(uv * symbol_scale) - 0.5;
	float r = hash(cell);
	float vertical = smoothstep(0.08, 0.025, abs(f.x));
	float horizontal = smoothstep(0.08, 0.025, abs(f.y));
	float slash = smoothstep(0.07, 0.025, abs(f.x - f.y));
	float corner = max(
		smoothstep(0.06, 0.025, abs(abs(f.x) - 0.28)) * step(0.10, abs(f.y)),
		smoothstep(0.06, 0.025, abs(abs(f.y) - 0.28)) * step(0.10, abs(f.x))
	);
	float mark = mix(vertical, horizontal, step(0.25, r));
	mark = mix(mark, slash, step(0.50, r));
	mark = mix(mark, corner, step(0.75, r));
	return mark;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * drift_speed;
	uv.x += sin(uv.y * 11.0 + t * 3.0 + seed) * 0.018 * intensity;
	uv.y += t * (0.45 + hash(vec2(seed, 1.0)) * 0.35);
	float g1 = glyph(uv);
	float g2 = glyph(vec2(1.0 - uv.x, uv.y + 0.17 + failure * 0.2));
	float fail_pulse = smoothstep(0.62, 1.0, sin(TIME * 4.0 + seed * 2.0) * 0.5 + 0.5) * failure;
	float mask = max(g1, g2 * (0.35 + failure * 0.65));
	vec3 color = mix(ink_color.rgb, glow_color.rgb, fail_pulse);
	ALBEDO = color;
	ALPHA = clamp(alpha * mask * intensity * (0.8 + fail_pulse * 0.45), 0.0, 0.75);
}
