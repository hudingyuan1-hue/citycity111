shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 base_color : source_color = vec4(0.62, 0.64, 0.62, 0.35);
uniform float alpha = 0.35;
uniform float noise_scale = 5.0;
uniform float flow_speed = 0.08;
uniform float distortion = 0.18;
uniform float seed = 1.0;
uniform float pulse_strength = 0.25;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 19.19) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amplitude;
		p *= 2.03;
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	float wave = fbm(VERTEX.xz * 0.12 + vec2(TIME * flow_speed, seed));
	VERTEX.y += (wave - 0.5) * distortion;
}

void fragment() {
	vec2 flow = UV * noise_scale + vec2(TIME * flow_speed, -TIME * flow_speed * 0.7 + seed);
	float cloud = fbm(flow);
	float streak = smoothstep(0.35, 0.82, cloud);
	float pulse = 0.5 + 0.5 * sin(TIME * 0.9 + seed * 5.0);
	ALBEDO = base_color.rgb + streak * pulse_strength;
	ALPHA = clamp(alpha * (0.45 + streak * 0.85 + pulse * 0.12), 0.0, 1.0);
}
