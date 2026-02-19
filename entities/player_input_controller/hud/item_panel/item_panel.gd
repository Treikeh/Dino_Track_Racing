extends MarginContainer


@export var _panel: PanelContainer
@export var _item_list: Control


func _ready() -> void:
	_panel.hide()
	_item_list.material.set("shader_parameter/scroll_speed", 0.0)


func picked_up_item(item: ItemResource) -> void:
	_panel.show()
	
	var item_offset: float = 0.143
	match item.name:
		"Lance": item_offset *= 0
		"Bomb": item_offset *= 1
		"Mine": item_offset *= 2
		"Missile": item_offset *= 3
		"Trash Bag": item_offset *= 4
		"Boost": item_offset *= 5
		"Meteor Rain": item_offset *= 6
		_: item_offset = 0.5
	
	_item_list.material.set("shader_parameter/scroll_speed", 2.0 + item_offset)
	
	const TWEEN_DURATION: float = 1.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_item_list.material, "shader_parameter/scroll_speed", item_offset, TWEEN_DURATION)
	AudioWorldUi.play_sound(SfxUI.Type.ITEM_RECIVED)


func used_item() -> void:
	_panel.hide()
