shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform float refraction_str : hint_range(0.0, 1.0) = 0.5;
uniform float refractive_index : hint_range(1.0, 1.3) = 1.2;
uniform float distortion_strength = 0.02;
uniform float visibility = 0.15;

uniform sampler2D player_tex;
uniform sampler2D normal_map : hint_normal;
uniform sampler2D screen_tex : hint_screen_texture;

varying vec3 world_normal;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_NORMAL_MATRIX * NORMAL));
}

void fragment() {
	vec3 N = normalize(world_normal);
	vec3 V = normalize(CAMERA_POSITION_WORLD - world_pos);
	vec3 R = refract(-V, N, 1.0 / refractive_index);

	vec2 offset = R.xy * distortion_strength;
	float fresnel = pow(1.0 - max(dot(N, V), 0.0), 5.0);
	
	vec3 ref_color = texture(screen_tex, SCREEN_UV + offset).rgb;
	vec3 tex_color = texture(player_tex, UV).rgb;
	
	vec3 color = mix(tex_color, ref_color, refraction_str);
	
	ALBEDO = color;
	
	float tex_alpha = 1.0f - refraction_str;
	float ref_alpha = fresnel * clamp(visibility, -0.9f, 0.9f);
	
	ALPHA = mix(tex_alpha, ref_alpha, refraction_str);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
