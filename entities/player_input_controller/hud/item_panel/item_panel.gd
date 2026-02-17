extends MarginContainer


@export var _panel: PanelContainer
@export var _item_list: Control


func _ready() -> void:
	_panel.hide()
	_item_list.material.set("shader_parameter/scroll_speed", 0.0)


func picked_up_item(item: ItemResource) -> void:
	_panel.show()
	
	var item_offset: float = 0.0
	match item.name:
		"Lance": item_offset = 0.0
		"Bomb": item_offset = 0.25
		"Mine": item_offset = 0.5
		"Missile": item_offset = 0.75
		_: item_offset = 0.33
	
	_item_list.material.set("shader_parameter/scroll_speed", 2.0 + item_offset)
	
	const TWEEN_DURATION: float = 1.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_item_list.material, "shader_parameter/scroll_speed", item_offset, TWEEN_DURATION)
	AudioWorldUi.play_sound(SfxUI.Type.ITEM_RECIVED)


func used_item() -> void:
	_panel.hide()
