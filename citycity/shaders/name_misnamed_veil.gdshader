shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 tint : source_color = vec4(0.84, 0.80, 0.62, 0.22);
uniform float alpha : hint_range(0.0, 1.0) = 0.22;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float name_drift : hint_range(0.0, 1.0) = 0.42;
uniform float seed = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p + seed, vec2(41.7, 289.3))) * 19341.127);
}

float name_fragment(vec2 uv) {
	vec2 drift_uv = uv;
	drift_uv.x += sin(TIME * 0.18 + uv.y * 8.0 + seed) * 0.025 * name_drift;
	drift_uv.y += cos(TIME * 0.12 + uv.x * 5.0 + seed) * 0.015 * name_drift;
	vec2 grid = drift_uv * vec2(10.0, 5.0);
	vec2 id = floor(grid);
	vec2 cell = fract(grid);
	float h = hash21(id);
	float stroke_a = smoothstep(0.030, 0.0, abs(cell.y - mix(0.28, 0.72, h)));
	float stroke_b = smoothstep(0.025, 0.0, abs(cell.x - mix(0.20, 0.80, hash21(id + 9.8))));
	float broken = step(0.42, h) * step(cell.x, 0.86) * step(0.12, cell.x);
	float fade = smoothstep(0.10, 0.80, sin(TIME * 0.36 + h * 6.283 + seed) * 0.5 + 0.5);
	return clamp(max(stroke_a, stroke_b * 0.55) * broken * fade, 0.0, 1.0);
}

void fragment() {
	float glyph = name_fragment(UV);
	float soft_band = smoothstep(0.0, 0.22, UV.y) * smoothstep(1.0, 0.70, UV.y);
	float edge_fade = smoothstep(0.0, 0.12, UV.x) * smoothstep(1.0, 0.88, UV.x);
	float mist = (0.08 + glyph * 0.92) * soft_band * edge_fade;
	ALBEDO = tint.rgb;
	EMISSION = tint.rgb * (0.16 + glyph * intensity);
	ALPHA = alpha * mist;
}
