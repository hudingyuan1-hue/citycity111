shader_type spatial;
render_mode blend_mix, cull_back, depth_prepass_alpha, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.46, 0.43, 0.30, 1.0);
uniform vec4 fog_color : source_color = vec4(0.62, 0.58, 0.38, 1.0);
uniform vec4 dirt_color : source_color = vec4(0.10, 0.09, 0.065, 1.0);
uniform float alpha = 1.0;
uniform float grime_strength = 0.58;
uniform float repeat_strength = 0.92;
uniform float low_contrast = 0.44;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 19.37) * 43758.5453123);
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
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amplitude;
		p *= 2.13;
		amplitude *= 0.52;
	}
	return value;
}

void fragment() {
	vec2 tiled = UV * (7.0 + repeat_strength * 11.0);
	vec2 cell = abs(fract(tiled) - 0.5);
	float repeat_line = smoothstep(0.455, 0.50, max(cell.x, cell.y));
	float soot = fbm(UV * (13.0 + repeat_strength * 8.0) + vec2(seed, TIME * 0.015));
	float stain = smoothstep(0.46, 0.88, soot) * grime_strength;
	float paper_patch = step(0.82, hash(floor(tiled * 0.45 + seed)));
	float vertical_dirt = smoothstep(0.18, 0.92, sin(UV.y * 18.0 + seed) * 0.5 + 0.5) * stain;
	vec3 color = mix(base_color.rgb, fog_color.rgb, 0.16 + stain * 0.18);
	color = mix(color, dirt_color.rgb, clamp(stain * 0.52 + vertical_dirt * 0.28, 0.0, 0.78));
	color = mix(color, fog_color.rgb, repeat_line * repeat_strength * 0.10);
	color = mix(color, base_color.rgb * vec3(1.08, 1.05, 0.86), paper_patch * 0.08);
	float luma = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(luma), clamp(low_contrast, 0.0, 0.82));
	ALBEDO = color;
	ROUGHNESS = clamp(0.86 + stain * 0.10, 0.0, 1.0);
	SPECULAR = clamp(0.18 - stain * 0.08, 0.0, 1.0);
	ALPHA = alpha;
}
