shader_type canvas_item;

uniform float rot_amount = 90.0;
uniform float scroll_speed = 0.1;
uniform sampler2D item_list_texture : filter_nearest, repeat_enable;
uniform sampler2D mask_gradient;


vec2 rotateUV(vec2 uv, float rotation) {
	float rad = rotation / 180.0 * PI;
	float mid = 0.5;
	float x = cos(rad) * (uv.x - mid) + sin(rad) * (uv.y - mid) + mid;
	float y = cos(rad) * (uv.y - mid) - sin(rad) * (uv.x - mid) + mid;
	return vec2(x, y);
}


void fragment() {
	vec2 scroll_uv = UV + (vec2(0, scroll_speed));
	vec2 rot_uv = rotateUV(UV, rot_amount);
	COLOR = texture(item_list_texture, scroll_uv) * texture(mask_gradient, rot_uv);
}
