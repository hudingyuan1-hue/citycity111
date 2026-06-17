shader_type spatial;
render_mode blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 water_color : source_color = vec4(0.32, 0.68, 0.86, 0.62);
uniform vec4 gleam_color : source_color = vec4(0.88, 0.96, 1.0, 0.42);
uniform float alpha = 0.62;
uniform float wave_strength = 0.10;
uniform float ripple_scale = 8.0;
uniform float mirror_brightness = 0.38;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 13.19) * 43758.5453123);
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

void vertex() {
	float n = noise(VERTEX.xz * 0.08 + vec2(TIME * 0.05, seed));
	VERTEX.y += (n - 0.5) * wave_strength;
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float rings = sin(length(uv) * ripple_scale * 6.28318 - TIME * 1.4 + seed);
	float shimmer = noise(UV * 18.0 + vec2(TIME * 0.08, -TIME * 0.05 + seed));
	float pupil = smoothstep(0.035, 0.0, abs(length(uv) - 0.22));
	vec3 color = water_color.rgb;
	color += gleam_color.rgb * (0.20 + shimmer * mirror_brightness + max(rings, 0.0) * 0.08 + pupil * 0.35);
	ALBEDO = color;
	ALPHA = clamp(alpha * (0.78 + shimmer * 0.22), 0.0, 0.9);
	ROUGHNESS = 0.12;
	METALLIC = 0.0;
}
