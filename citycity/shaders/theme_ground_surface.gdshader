shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.45, 0.42, 0.34, 0.55);
uniform vec4 accent_color : source_color = vec4(0.80, 0.68, 0.38, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.06, 0.06, 0.05, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.76, 0.34, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.55;
uniform float theme_mode = 0.0;
uniform float intensity : hint_range(0.0, 1.5) = 0.72;
uniform float motion : hint_range(0.0, 1.0) = 0.16;
uniform float seed = 0.0;
uniform float scale : hint_range(1.0, 16.0) = 6.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += value_noise(p) * a;
		p = p * 2.03 + vec2(13.1, 7.7);
		a *= 0.5;
	}
	return v;
}

float ring_field(vec2 uv, float density) {
	vec2 centered = uv - vec2(0.5);
	float r = length(centered);
	return 0.5 + 0.5 * sin(r * density - TIME * (0.45 + motion) + seed * 0.021);
}

float soft_band(vec2 uv, float angle, float density) {
	vec2 dir = vec2(cos(angle), sin(angle));
	float b = dot(uv, dir) * density + seed * 0.033 + TIME * motion;
	return 0.5 + 0.5 * sin(b);
}

void fragment() {
	vec2 uv = UV * scale + vec2(seed * 0.013, seed * 0.021);
	float n = fbm(uv + TIME * motion * vec2(0.08, -0.035));
	float n2 = fbm(uv * 1.87 - TIME * motion * vec2(0.035, 0.065));
	float grain = hash21(floor(uv * 46.0 + seed));
	float detail = n;
	float glow = 0.0;
	float rough = 0.86;
	float metallic = 0.0;
	vec3 base = base_color.rgb;
	vec3 accent = accent_color.rgb;
	vec3 shade = shadow_color.rgb;

	if (theme_mode < 0.5) {
		float rings = ring_field(UV, 34.0);
		float dust = step(0.94, grain) * 0.22;
		detail = mix(n * 0.72, rings, 0.30) + dust;
		base = mix(base, vec3(0.62, 0.50, 0.36), 0.20);
		glow = dust * 0.05;
		rough = 0.92;
	} else if (theme_mode < 1.5) {
		float dunes = soft_band(uv, 0.22, 1.85);
		float heat = fbm(uv * vec2(1.0, 0.35) + TIME * motion * vec2(0.8, 0.0));
		detail = mix(dunes, heat, 0.34);
		accent = mix(accent, vec3(1.0, 0.58, 0.16), 0.42);
		glow = pow(max(0.0, detail - 0.58), 2.0) * 0.16;
		rough = 0.42;
		metallic = 0.04;
	} else if (theme_mode < 2.5) {
		float hard = step(0.58, n);
		float band = step(0.70, soft_band(uv, 1.57, 2.8));
		detail = mix(hard, band, 0.28);
		base = mix(base, vec3(0.84, 0.78, 0.58), 0.22);
		accent = mix(accent, vec3(0.04, 0.04, 0.035), 0.34);
		rough = 0.88;
	} else if (theme_mode < 3.5) {
		float cloud = fbm(uv * 0.62 + TIME * motion * vec2(0.0, 0.10));
		float air = smoothstep(0.34, 0.88, cloud);
		detail = air;
		base = mix(base, vec3(0.70, 0.86, 0.98), 0.20);
		glow = air * 0.035;
		rough = 0.58;
	} else if (theme_mode < 4.5) {
		float wet = smoothstep(0.40, 0.78, n2);
		float glint = step(0.985, grain) * wet;
		detail = wet + glint * 0.35;
		accent = mix(accent, vec3(0.08, 0.62, 0.44), 0.34);
		glow = glint * 0.18;
		rough = 0.18;
	} else if (theme_mode < 5.5) {
		float ripple = ring_field(UV + vec2(n * 0.03, n2 * 0.02), 46.0);
		float mirror = smoothstep(0.48, 0.86, ripple);
		detail = mix(n * 0.36, mirror, 0.62);
		accent = mix(accent, vec3(0.72, 0.94, 1.0), 0.40);
		glow = mirror * 0.075;
		rough = 0.14;
		metallic = 0.03;
	} else if (theme_mode < 6.5) {
		float strokes = smoothstep(0.66, 0.78, abs(sin((uv.x * 1.7 + uv.y * 0.42 + seed) * 5.0)));
		float dust = step(0.965, grain) * 0.18;
		detail = mix(n * 0.66, strokes, 0.22) + dust;
		base = mix(base, vec3(0.58, 0.55, 0.48), 0.28);
		glow = strokes * 0.035;
		rough = 0.94;
	} else if (theme_mode < 7.5) {
		float salt = smoothstep(0.36, 0.72, n);
		float ash = step(0.955, grain) * 0.25;
		detail = salt + ash;
		base = mix(base, vec3(0.62, 0.64, 0.66), 0.22);
		accent = mix(accent, vec3(0.52, 0.68, 1.0), 0.22);
		glow = ash * 0.04;
		rough = 0.98;
	} else if (theme_mode < 8.5) {
		float stars = step(0.988, grain);
		float orbit = smoothstep(0.72, 0.92, ring_field(UV, 58.0));
		detail = n * 0.34 + orbit * 0.34 + stars * 0.62;
		base = mix(base, vec3(0.10, 0.14, 0.34), 0.30);
		accent = mix(accent, vec3(0.58, 0.72, 1.0), 0.32);
		glow = stars * 0.30 + orbit * 0.06;
		rough = 0.36;
	} else if (theme_mode < 9.5) {
		float stains = smoothstep(0.44, 0.82, n2);
		float repeat = smoothstep(0.74, 0.86, abs(sin(uv.x * 1.6 + seed * 0.02)));
		detail = mix(stains, repeat, 0.20);
		base = mix(base, vec3(0.36, 0.34, 0.24), 0.28);
		accent = mix(accent, vec3(0.68, 0.58, 0.30), 0.22);
		rough = 0.96;
	} else {
		float undergrowth = smoothstep(0.50, 0.86, n);
		float dim_mote = step(0.992, grain);
		detail = undergrowth * 0.42 + dim_mote * 0.30;
		base = mix(base, vec3(0.035, 0.095, 0.055), 0.35);
		accent = mix(accent, vec3(0.16, 0.36, 0.18), 0.30);
		glow = dim_mote * 0.075;
		rough = 0.90;
	}

	detail = clamp(detail, 0.0, 1.0);
	vec3 color = mix(base, accent, detail * intensity * 0.62);
	color = mix(color, shade, (1.0 - detail) * intensity * 0.18);
	float local_alpha = clamp(alpha, 0.0, 1.0);

	ALBEDO = color;
	ALPHA = local_alpha;
	ROUGHNESS = clamp(rough, 0.02, 1.0);
	METALLIC = metallic;
	SPECULAR = clamp(0.18 + (1.0 - rough) * 0.42, 0.04, 0.80);
	EMISSION = glow_color.rgb * glow * intensity;
}
