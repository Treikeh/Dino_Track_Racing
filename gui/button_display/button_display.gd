@tool
extends HBoxContainer


@export var _front_text: String = "Front" :
	set(value): # Setter to update the dispaly when _front_text changes
		_front_text = value
		if _front_label:
			_front_label.text = value

@export var _button_texture: Texture2D:
	set(value): # Setter to update the dispaly when _button_texture changes
		_button_texture = value
		if _texture_rect:
			_texture_rect.texture = value

@export var _back_text: String = "back":
	set(value): # Setter to update the dispaly when _back_text changes
		_back_text = value
		if _back_label:
			_back_label.text = value

@export_group("Nodes")
@export var _front_label: Label
@export var _texture_rect: TextureRect
@export var _back_label: Label
