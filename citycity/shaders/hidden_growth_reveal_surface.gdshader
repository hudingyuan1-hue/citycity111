shader_type spatial;
render_mode blend_mix, cull_back, depth_prepass_alpha, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.12, 0.18, 0.11, 1.0);
uniform vec4 growth_color : source_color = vec4(0.10, 0.54, 0.18, 1.0);
uniform vec4 glow_color : source_color = vec4(0.50, 1.0, 0.62, 1.0);
uniform float alpha = 1.0;
uniform float reveal_strength = 0.50;
uniform float growth_strength = 0.62;
uniform float mask_softness = 0.28;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 29.13) * 43758.5453123);
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

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 5; i++) {
		value += noise(p) * amplitude;
		p *= 2.04;
		amplitude *= 0.53;
	}
	return value;
}

void fragment() {
	vec2 uv = UV * 6.0;
	float t = TIME * 0.12;
	float hidden_mask = fbm(uv + vec2(seed * 0.11 + t, -t * 0.7));
	float reveal = smoothstep(0.48 - mask_softness * 0.20, 0.78, hidden_mask + reveal_strength * 0.18);
	float vein = 1.0 - smoothstep(0.0, 0.045 + growth_strength * 0.025, abs(hidden_mask - 0.54));
	float leaf_cell = step(0.82, hash(floor(uv * 1.7 + seed)));
	vec3 color = mix(base_color.rgb * 0.44, base_color.rgb, reveal);
	color = mix(color, growth_color.rgb, clamp((vein * 0.46 + leaf_cell * 0.18) * growth_strength, 0.0, 0.82));
	float edge = 1.0 - smoothstep(0.0, 0.08, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	ALBEDO = color;
	EMISSION = glow_color.rgb * (vein * 0.10 + edge * 0.04) * reveal_strength;
	ROUGHNESS = clamp(0.82 - reveal * 0.16 + growth_strength * 0.08, 0.18, 1.0);
	SPECULAR = clamp(0.18 + reveal * 0.18, 0.0, 0.6);
	ALPHA = clamp(alpha * (0.58 + reveal * 0.42), 0.0, 1.0);
}
