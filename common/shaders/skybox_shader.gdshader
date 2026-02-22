shader_type spatial;
render_mode unshaded;

uniform vec2 offset;
uniform vec2 scroll_speed;
uniform sampler2D color_texture: source_color, filter_nearest_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv_pos = UV + (TIME * scroll_speed) + offset;
	ALBEDO = texture(color_texture, uv_pos).rgb * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
