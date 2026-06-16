shader_type spatial;
render_mode blend_mix, cull_back, depth_prepass_alpha, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.62, 0.48, 0.28, 1.0);
uniform vec4 lantern_color : source_color = vec4(1.0, 0.52, 0.18, 1.0);
uniform vec4 neon_color : source_color = vec4(0.08, 0.72, 0.68, 1.0);
uniform float alpha = 1.0;
uniform float wetness = 0.58;
uniform float lantern_glow = 0.22;
uniform float neon_mix = 0.12;
uniform float material_mix = 0.42;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 23.17) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

void fragment() {
	vec2 uv = UV * 8.0;
	float puddle = smoothstep(0.48, 0.88, noise(uv + vec2(TIME * 0.05, seed)));
	float market_patch = hash(floor(uv * 0.72 + seed));
	float lantern_band = smoothstep(0.35, 0.98, sin(UV.y * 16.0 + TIME * 0.9 + seed) * 0.5 + 0.5);
	float neon_line = smoothstep(0.93, 0.985, fract(UV.x * (5.0 + neon_mix * 5.0) + seed * 0.11 + sin(TIME * 0.4) * 0.03));
	vec3 mixed = mix(base_color.rgb, vec3(base_color.b, base_color.r * 0.86, base_color.g), market_patch * material_mix);
	vec3 lit = mix(mixed, lantern_color.rgb, lantern_band * lantern_glow);
	lit = mix(lit, neon_color.rgb, neon_line * neon_mix);
	ALBEDO = lit;
	EMISSION = lantern_color.rgb * lantern_band * lantern_glow * 0.12 + neon_color.rgb * neon_line * neon_mix * 0.42;
	ROUGHNESS = clamp(0.82 - wetness * (0.46 + puddle * 0.32), 0.12, 0.92);
	SPECULAR = clamp(0.24 + wetness * (0.52 + puddle * 0.24), 0.0, 1.0);
	METALLIC = clamp(neon_mix * 0.08 + material_mix * market_patch * 0.05, 0.0, 0.18);
	ALPHA = alpha;
}
