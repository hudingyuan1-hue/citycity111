shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 tint : source_color = vec4(1.0, 0.75, 0.25, 0.25);
uniform float alpha = 0.25;
uniform float style_mode = 0.0;
uniform float intensity = 1.0;
uniform float seed = 1.0;
uniform float flow_speed = 0.18;
uniform float noise_scale = 4.5;
uniform float vertical_wave = 0.35;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 17.31) * 43758.5453123);
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
		p *= 2.07;
		amplitude *= 0.52;
	}
	return value;
}

void vertex() {
	float n = fbm(VERTEX.xz * 0.09 + vec2(TIME * flow_speed, seed));
	float heat = sin(VERTEX.y * 2.2 + TIME * 2.1 + seed) * 0.08;
	VERTEX.x += (n - 0.5) * vertical_wave * intensity;
	VERTEX.z += heat * style_mode * intensity;
}

void fragment() {
	vec2 uv = UV * noise_scale;
	float t = TIME * flow_speed;
	float cloud = fbm(uv + vec2(t + seed, -t * 0.8));
	float streak = smoothstep(0.30, 0.78, cloud);
	float film_gate = step(0.92, fract((UV.x + seed * 0.13) * 11.0 + sin(TIME * 0.33) * 0.08));
	float heat_band = smoothstep(0.42, 0.96, sin((UV.y * 28.0) + TIME * 1.6 + seed) * 0.5 + 0.5);
	float memory_layer = streak * (0.68 + film_gate * 0.32);
	float desire_layer = max(streak * 0.72, heat_band * 0.55);
	float mask = mix(memory_layer, desire_layer, clamp(style_mode, 0.0, 1.0));
	vec3 memory_color = mix(tint.rgb, vec3(1.0, 0.78, 0.28), film_gate * 0.35);
	vec3 desire_color = mix(tint.rgb, vec3(1.0, 0.35, 0.12), heat_band * 0.45);
	ALBEDO = mix(memory_color, desire_color, clamp(style_mode, 0.0, 1.0)) * (0.72 + mask * 0.45 * intensity);
	ALPHA = clamp(alpha * mask * intensity, 0.0, 0.85);
}
