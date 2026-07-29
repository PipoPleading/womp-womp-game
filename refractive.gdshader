shader_type spatial;
render_mode blend_mix;

uniform float refractive_index : hint_range(1.0, 1.3) = 1.2;
uniform float distortion_strength = 0.02;
uniform float visibility = 0.15;

uniform sampler2D normal_map : hint_normal;
uniform sampler2D screen_tex : hint_screen_texture;

varying vec3 world_normal;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 N = world_normal;
	
	vec3 normal_tex = texture(normal_map, UV).rgb;
    normal_tex = normal_tex * 2.0 - 1.0;
    N = normalize(N + normal_tex);
	
	vec3 V = normalize(CAMERA_POSITION_WORLD - world_pos);
	vec3 R = refract(-V, N, 1.0 / refractive_index);
	
	vec2 offset = R.xy * distortion_strength;
	float fresnel = pow(1.0 - max(dot(N, V), 0.0), 5.0);
	
	vec3 color = texture(screen_tex, SCREEN_UV + offset).rgb;
	
	ALBEDO = color;
	ALPHA = fresnel * visibility;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
