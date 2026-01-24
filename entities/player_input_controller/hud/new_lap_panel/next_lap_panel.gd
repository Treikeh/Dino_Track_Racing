extends Control


@export var _dino_image: TextureRect
@export var _lap_label: Label


func _ready() -> void:
	hide()
	size.y = _dino_image.size.y


func update(lap: int, total_laps: int) -> void:
	_lap_label.text = "%s/%s" % [lap, total_laps]
