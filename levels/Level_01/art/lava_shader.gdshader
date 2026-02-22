shader_type spatial;
render_mode unshaded;

uniform sampler2D displacement_map;
uniform sampler2D color_texture: source_color, filter_nearest_mipmap;


float height(vec2 position, float time) {
	vec2 offset = 0.01 * cos(position + time);
	return texture(displacement_map, (position / 10.0) - offset).x - 0.25;
}


void vertex() {
	vec2 pos = VERTEX.xz;
	float displacement = height(pos, TIME);
	VERTEX.y += displacement * 2.0;
}

void fragment() {
	ALPHA = texture(color_texture, UV).a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	vec2 uv_pos = UV + (TIME * 0.1);
	ALBEDO = texture(color_texture, uv_pos).rgb * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
