shader_type spatial;
render_mode unshaded;

uniform vec2 scroll_speed;
uniform sampler2D color_texture: source_color, filter_nearest_mipmap;

void fragment() {
	vec2 scroll_uv = UV + (TIME * 0.1) * (vec2(scroll_speed.x, scroll_speed.y));
	ALPHA = texture(color_texture, scroll_uv).a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = texture(color_texture, scroll_uv).rgb * COLOR.rgb;
}
