extends PanelContainer


@export var _lap_label: Label


func _ready() -> void:
	hide()


func update(lap: int, total_laps: int) -> void:
	_lap_label.text = "%s/%s" % [lap, total_laps]
