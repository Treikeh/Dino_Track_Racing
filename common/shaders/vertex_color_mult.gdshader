shader_type spatial;
render_mode unshaded;

uniform sampler2D color_texture: source_color, filter_nearest_mipmap;

void fragment() {
	ALPHA = texture(color_texture, UV).a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = texture(color_texture, UV).rgb * COLOR.rgb;
}