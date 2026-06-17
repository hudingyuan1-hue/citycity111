shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.12, 0.16, 0.32, 1.0);
uniform vec4 star_color : source_color = vec4(0.72, 0.86, 1.0, 1.0);
uniform vec4 gold_color : source_color = vec4(1.0, 0.76, 0.28, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float star_strength : hint_range(0.0, 2.0) = 0.35;
uniform float line_strength : hint_range(0.0, 2.0) = 0.28;
uniform float seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32 + seed * 0.013);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv = UV * (9.0 + mod(abs(seed), 5.0));
	vec2 cell = floor(uv);
	vec2 local = fract(uv);
	float h = hash21(cell);
	float star_mask = step(0.955, h);
	float star_core = 1.0 - smoothstep(0.0, 0.24, length(local - vec2(0.5)));
	float star = star_mask * star_core;

	float line_seed = step(0.74, hash21(cell + vec2(19.3, 7.1)));
	float horizontal = 1.0 - smoothstep(0.012, 0.055, abs(local.y - 0.5));
	float vertical = 1.0 - smoothstep(0.012, 0.055, abs(local.x - 0.5));
	float constellation_line = line_seed * max(horizontal, vertical) * 0.55;

	float slow_pulse = 0.55 + 0.45 * sin(TIME * 0.45 + seed + h * 6.28318);
	vec3 color = base_color.rgb;
	color = mix(color, star_color.rgb, clamp(star * star_strength * 1.35, 0.0, 1.0));
	color = mix(color, gold_color.rgb, clamp(constellation_line * line_strength * 0.38, 0.0, 0.55));
	ALBEDO = color;
	EMISSION = star_color.rgb * star * star_strength * slow_pulse + gold_color.rgb * constellation_line * line_strength * 0.35;
	ROUGHNESS = 0.78;
	ALPHA = base_color.a * alpha;
}
