shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec4 tint : source_color = vec4(0.60, 0.86, 1.0, 0.24);
uniform float alpha = 0.24;
uniform float intensity = 1.0;
uniform float offset_strength = 0.16;
uniform float seed = 1.0;
uniform float split = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 19.73) * 43758.5453123);
}

float bands(vec2 uv) {
	float b = sin((uv.y * 18.0 + TIME * 0.45 + seed) * 6.28318);
	float c = sin((uv.x * 7.0 - TIME * 0.22 + seed) * 6.28318);
	return smoothstep(0.25, 0.92, b * 0.5 + c * 0.25 + 0.5);
}

void vertex() {
	float drift = sin(VERTEX.y * 0.7 + TIME * 0.8 + seed) * offset_strength * intensity;
	VERTEX.x += drift;
	VERTEX.z += sin(VERTEX.x * 0.09 + TIME * 0.45 + seed) * offset_strength * 0.35 * intensity;
}

void fragment() {
	float mask = bands(UV);
	float double_image = smoothstep(0.44, 0.48, abs(fract(UV.x * 3.0 + seed * 0.13 + TIME * 0.03) - 0.5));
	vec3 color = mix(tint.rgb, vec3(0.92, 0.98, 1.0), double_image * split);
	ALBEDO = color;
	ALPHA = clamp(alpha * intensity * (0.35 + mask * 0.75 + double_image * 0.16), 0.0, 0.72);
}
