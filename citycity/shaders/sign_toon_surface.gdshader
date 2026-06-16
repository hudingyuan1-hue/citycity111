shader_type spatial;
render_mode blend_mix, cull_back, diffuse_toon, specular_toon;

uniform vec4 base_color : source_color = vec4(0.78, 0.76, 0.64, 1.0);
uniform vec4 ink_color : source_color = vec4(0.03, 0.03, 0.028, 1.0);
uniform float contrast = 0.72;
uniform float rim_strength = 0.45;
uniform float hatch_strength = 0.18;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 9.73) * 43758.5453123);
}

void fragment() {
	float bands = floor(UV.y * 18.0 + seed);
	float hatch = step(0.78, hash(vec2(bands, floor(UV.x * 6.0))));
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	vec3 color = mix(base_color.rgb, ink_color.rgb, hatch * hatch_strength);
	color = mix(color, ink_color.rgb, rim * rim_strength);
	ALBEDO = mix(vec3(dot(color, vec3(0.299, 0.587, 0.114))), color, 1.0 - contrast * 0.55);
	ROUGHNESS = 0.92;
}
