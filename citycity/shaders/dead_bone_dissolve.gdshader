shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.38, 0.36, 0.32, 1.0);
uniform vec4 bone_color : source_color = vec4(0.82, 0.80, 0.70, 1.0);
uniform vec4 cold_glow_color : source_color = vec4(0.38, 0.58, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float dissolve_strength : hint_range(0.0, 1.0) = 0.22;
uniform float cold_glow : hint_range(0.0, 2.0) = 0.16;
uniform float seed = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p + seed, vec2(113.7, 271.9))) * 41731.113);
}

float slow_dissolve(vec2 uv) {
	float n1 = hash21(floor((uv + vec2(TIME * 0.018, -TIME * 0.012)) * 26.0));
	float n2 = hash21(floor((uv + vec2(seed * 0.013, seed * 0.021)) * 8.0));
	float band = smoothstep(0.18, 0.86, sin(uv.y * 8.0 + TIME * 0.22 + seed) * 0.5 + 0.5);
	return clamp(n1 * 0.58 + n2 * 0.30 + band * 0.12, 0.0, 1.0);
}

void fragment() {
	float grain = hash21(floor(UV * vec2(72.0, 54.0)));
	float dissolve = slow_dissolve(UV);
	float edge = smoothstep(0.48, 0.62, dissolve) * dissolve_strength;
	float bone_mix = smoothstep(0.35, 0.78, grain + edge * 0.65);
	vec3 color = mix(base_color.rgb, bone_color.rgb, bone_mix * 0.55);
	color *= 0.72 + grain * 0.16;
	ALBEDO = color;
	ROUGHNESS = 0.92;
	METALLIC = 0.0;
	EMISSION = cold_glow_color.rgb * edge * cold_glow;
	ALPHA = alpha * (1.0 - edge * 0.22);
}
