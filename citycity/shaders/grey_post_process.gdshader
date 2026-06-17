shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float effect_strength = 0.55;
uniform float grain_strength = 0.24;
uniform float halftone_strength = 0.0;
uniform float pixel_strength = 0.08;
uniform float posterize_strength = 0.12;
uniform float flatten_strength = 0.14;
uniform float scanline_strength = 0.0;
uniform float chromatic_strength = 0.0012;
uniform float wave_strength = 0.0025;
uniform float edge_strength = 0.0;
uniform float contour_strength = 0.0;
uniform float solarize_strength = 0.0;
uniform float inversion_flicker_strength = 0.0;
uniform float vignette_strength = 0.18;
uniform float zone_tint_strength = 0.12;
uniform vec3 zone_tint = vec3(0.78, 0.76, 0.68);
uniform float ink_outline_strength = 0.0;
uniform float ink_outline_width = 1.0;
uniform float stylized_shadow_strength = 0.0;
uniform float color_variation_strength = 0.0;
uniform float soft_glow_strength = 0.0;
uniform vec3 ink_color = vec3(0.025, 0.027, 0.024);
uniform vec3 shadow_color = vec3(0.08, 0.08, 0.075);
uniform float time_scale = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

vec3 posterize(vec3 c, float levels) {
	return floor(c * levels) / max(levels - 1.0, 1.0);
}

float cell_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d = 1.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(hash(i + g), hash(i + g + 13.7));
			vec2 r = g + o - f;
			d = min(d, dot(r, r));
		}
	}
	return sqrt(d);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME * time_scale;
	float wave = sin((uv.y * 38.0) + t * 1.7) * cos((uv.x * 21.0) - t * 1.1);
	uv += vec2(wave, -wave * 0.45) * wave_strength * effect_strength;

	vec2 pixel_grid = vec2(180.0, 105.0);
	vec2 pixel_uv = (floor(uv * pixel_grid) + 0.5) / pixel_grid;
	uv = mix(uv, pixel_uv, clamp(pixel_strength * effect_strength, 0.0, 1.0));

	vec2 chroma_offset = vec2(chromatic_strength * effect_strength, 0.0);
	vec3 col;
	col.r = texture(screen_texture, uv + chroma_offset).r;
	col.g = texture(screen_texture, uv).g;
	col.b = texture(screen_texture, uv - chroma_offset).b;

	float grey = luma(col);
	vec3 flat_col = vec3(grey);
	col = mix(col, flat_col, clamp(flatten_strength * effect_strength, 0.0, 1.0));
	col = mix(col, posterize(col, 5.0), clamp(posterize_strength * effect_strength, 0.0, 1.0));

	vec2 px = SCREEN_PIXEL_SIZE * max(ink_outline_width, 0.5);
	float l1 = luma(texture(screen_texture, uv + vec2(px.x, 0.0)).rgb);
	float l2 = luma(texture(screen_texture, uv - vec2(px.x, 0.0)).rgb);
	float l3 = luma(texture(screen_texture, uv + vec2(0.0, px.y)).rgb);
	float l4 = luma(texture(screen_texture, uv - vec2(0.0, px.y)).rgb);
	float ld1 = luma(texture(screen_texture, uv + px * vec2(1.0, 1.0)).rgb);
	float ld2 = luma(texture(screen_texture, uv + px * vec2(-1.0, -1.0)).rgb);
	float ld3 = luma(texture(screen_texture, uv + px * vec2(-1.0, 1.0)).rgb);
	float ld4 = luma(texture(screen_texture, uv + px * vec2(1.0, -1.0)).rgb);
	float edge = clamp(abs(l1 - l2) + abs(l3 - l4) + (abs(ld1 - ld2) + abs(ld3 - ld4)) * 0.55, 0.0, 1.0);
	float ink = smoothstep(0.045, 0.28, edge);
	col = mix(col, vec3(edge), clamp(edge_strength * effect_strength, 0.0, 1.0));
	col = mix(col, ink_color, clamp(ink * ink_outline_strength * effect_strength, 0.0, 0.92));

	float shadow_cell = hash(floor(FRAGCOORD.xy / 46.0) + vec2(floor(t * 1.3), 19.0));
	float shadow_band = 1.0 - smoothstep(0.26, 0.76, grey);
	float shadow_weight = shadow_band * (0.78 + shadow_cell * 0.22);
	col = mix(col, shadow_color, clamp(shadow_weight * stylized_shadow_strength * effect_strength, 0.0, 0.78));

	float glow_mask = smoothstep(0.62, 0.92, grey) * (1.0 - ink * 0.65);
	vec3 glow_sample = (
		texture(screen_texture, uv + px * vec2(2.0, 0.0)).rgb +
		texture(screen_texture, uv + px * vec2(-2.0, 0.0)).rgb +
		texture(screen_texture, uv + px * vec2(0.0, 2.0)).rgb +
		texture(screen_texture, uv + px * vec2(0.0, -2.0)).rgb
	) * 0.25;
	col = mix(col, max(col, glow_sample), clamp(glow_mask * soft_glow_strength * effect_strength, 0.0, 0.45));

	float color_cell = hash(floor(FRAGCOORD.xy / 74.0) + vec2(7.0, floor(t * 0.7)));
	vec3 variation_tint = mix(zone_tint, vec3(zone_tint.b, zone_tint.r, zone_tint.g), color_cell);
	col = mix(col, col * (0.86 + variation_tint * 0.26), clamp(color_variation_strength * effect_strength, 0.0, 0.35));

	float contour = smoothstep(0.92, 1.0, sin((grey * 18.0 + cell_noise(uv * 18.0) * 2.2 + t * 0.18) * 3.14159) * 0.5 + 0.5);
	col = mix(col, vec3(contour), clamp(contour_strength * effect_strength, 0.0, 1.0));

	vec3 solar = vec3(grey > 0.52 ? 1.0 - col.r : col.r, grey > 0.50 ? 1.0 - col.g : col.g, grey > 0.48 ? 1.0 - col.b : col.b);
	col = mix(col, solar, clamp(solarize_strength * effect_strength, 0.0, 1.0));
	float flicker_row = floor(uv.y * 90.0);
	float flicker = step(0.965, hash(vec2(floor(t * 12.0), flicker_row)));
	col = mix(col, 1.0 - col, clamp(inversion_flicker_strength * flicker * effect_strength, 0.0, 1.0));

	float grain = hash(floor(FRAGCOORD.xy) + vec2(t * 41.0, -t * 23.0)) - 0.5;
	col += grain * grain_strength * effect_strength;

	vec2 dot_uv = FRAGCOORD.xy / 7.0;
	vec2 dot_cell = fract(dot_uv) - 0.5;
	float dot_mask = smoothstep(0.33, 0.18, length(dot_cell));
	float half_luma = smoothstep(0.15, 0.85, grey);
	float halftone = mix(half_luma, dot_mask, 0.65);
	col = mix(col, vec3(halftone), clamp(halftone_strength * effect_strength, 0.0, 0.12));

	float scanline = sin(FRAGCOORD.y * 3.14159);
	col *= 1.0 - scanline_strength * effect_strength * (0.5 + 0.5 * scanline);

	float dist = distance(SCREEN_UV, vec2(0.5));
	float vignette = smoothstep(0.18, 0.78, dist);
	col *= 1.0 - vignette * vignette_strength * effect_strength;

	col = mix(col, col * zone_tint, clamp(zone_tint_strength * effect_strength, 0.0, 1.0));
	COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), 1.0);
}
