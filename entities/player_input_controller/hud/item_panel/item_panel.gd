extends PanelContainer


@export var _item_icon: TextureRect


func _ready() -> void:
	hide()


func picked_up_item(item: ItemResource) -> void:
	show()
	_item_icon.texture = item.icon


func used_item() -> void:
	hide()
