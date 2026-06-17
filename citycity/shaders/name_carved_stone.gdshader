shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.48, 0.46, 0.40, 1.0);
uniform vec4 rune_color : source_color = vec4(0.90, 0.84, 0.62, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float carving_strength : hint_range(0.0, 1.0) = 0.42;
uniform float inscription_glow : hint_range(0.0, 2.0) = 0.18;
uniform float seed = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453123);
}

float glyph_mask(vec2 uv) {
	vec2 grid = uv * vec2(15.0, 7.0) + vec2(seed * 0.071, seed * 0.043);
	vec2 cell = fract(grid);
	vec2 id = floor(grid);
	float h = hash21(id);
	float h2 = hash21(id + 17.23);
	float vertical = smoothstep(0.040, 0.0, abs(cell.x - mix(0.22, 0.78, h))) * step(0.16, cell.y) * step(cell.y, 0.86);
	float horizontal = smoothstep(0.045, 0.0, abs(cell.y - mix(0.28, 0.72, h2))) * step(0.14, cell.x) * step(cell.x, 0.88);
	float cut = step(0.34, h) * max(vertical, horizontal);
	float broken = smoothstep(0.18, 0.95, sin(TIME * 0.55 + h * 6.283 + seed) * 0.5 + 0.5);
	return clamp(cut * (0.35 + broken * 0.65), 0.0, 1.0);
}

void fragment() {
	float stone_noise = hash21(floor(UV * vec2(90.0, 55.0)));
	float large_noise = hash21(floor(UV * vec2(12.0, 8.0)));
	float glyph = glyph_mask(UV);
	vec3 stone = base_color.rgb * (0.78 + stone_noise * 0.16 + large_noise * 0.08);
	stone = mix(stone, rune_color.rgb * 0.72, glyph * carving_strength);
	ALBEDO = stone;
	ROUGHNESS = 0.90;
	METALLIC = 0.0;
	EMISSION = rune_color.rgb * glyph * inscription_glow;
	ALPHA = alpha;
}
