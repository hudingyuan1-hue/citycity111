shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 base_color : source_color = vec4(0.62, 0.64, 0.62, 0.35);
uniform float alpha = 0.35;
uniform float noise_scale = 5.0;
uniform float flow_speed = 0.08;
uniform float distortion = 0.18;
uniform float seed = 1.0;
uniform float pulse_strength = 0.25;
uniform float ink_strength = 0.14;
uniform float shadow_strength = 0.18;
uniform float color_variation_strength = 0.10;

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
	float ridge = 1.0 - smoothstep(0.0, 0.055, abs(cloud - 0.52));
	float shadow = (1.0 - smoothstep(0.25, 0.72, cloud)) * (0.75 + pulse * 0.25);
	float color_cell = hash(floor(UV * 6.0 + vec2(seed, TIME * 0.18)));
	vec3 color = base_color.rgb + streak * pulse_strength;
	color = mix(color, color * (0.86 + base_color.gbr * 0.20), color_variation_strength * color_cell);
	color = mix(color, vec3(0.07, 0.075, 0.07), clamp(shadow * shadow_strength, 0.0, 0.62));
	color = mix(color, vec3(0.025, 0.027, 0.024), clamp(ridge * ink_strength, 0.0, 0.68));
	ALBEDO = color;
	ALPHA = clamp(alpha * (0.45 + streak * 0.85 + pulse * 0.12 + ridge * 0.16), 0.0, 1.0);
}
