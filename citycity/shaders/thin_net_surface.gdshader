shader_type spatial;
render_mode blend_mix, cull_disabled, depth_prepass_alpha, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.58, 0.74, 0.86, 0.46);
uniform vec4 edge_color : source_color = vec4(0.88, 0.95, 1.0, 0.92);
uniform float alpha = 0.46;
uniform float edge_strength = 0.78;
uniform float wire_density = 7.0;
uniform float sway_amount = 0.035;
uniform float sway_speed = 0.9;
uniform float seed = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 19.37) * 43758.5453123);
}

void vertex() {
	float sway = sin(VERTEX.y * 1.9 + VERTEX.x * 0.21 + VERTEX.z * 0.17 + TIME * sway_speed + seed);
	float cross = sin(VERTEX.x * 0.12 - VERTEX.z * 0.16 + TIME * sway_speed * 0.73 + seed * 0.41);
	VERTEX.x += sway * sway_amount;
	VERTEX.z += cross * sway_amount * 0.65;
}

void fragment() {
	vec2 cell = fract(UV * wire_density);
	float grid_x = 1.0 - smoothstep(0.0, 0.055, min(cell.x, 1.0 - cell.x));
	float grid_y = 1.0 - smoothstep(0.0, 0.055, min(cell.y, 1.0 - cell.y));
	float local_edge = 1.0 - smoothstep(0.0, 0.070, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	float wire = max(local_edge, max(grid_x, grid_y) * 0.42);
	float drift = hash(floor(UV * wire_density + vec2(seed, TIME * 0.08)));
	vec3 body = mix(base_color.rgb, base_color.rgb + vec3(0.06, 0.08, 0.09), drift * 0.45);
	vec3 color = mix(body, edge_color.rgb, clamp(wire * edge_strength, 0.0, 1.0));
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.4);
	ALBEDO = color;
	EMISSION = edge_color.rgb * wire * 0.12 * edge_strength;
	ALPHA = clamp(alpha + wire * edge_color.a * 0.36 * edge_strength + fresnel * 0.10, 0.0, 0.86);
	ROUGHNESS = 0.82;
	SPECULAR = 0.22;
}
