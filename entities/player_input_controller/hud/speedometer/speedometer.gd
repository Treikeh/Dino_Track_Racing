extends PanelContainer


@export var _speedometer_bar: Range
@export var _speed_label: Label


func _ready() -> void:
	pivot_offset = size


func update(speed_khm: float) -> void:
	_speedometer_bar.value = speed_khm
	_speed_label.text = "%s kmh" % int(snappedf(speed_khm, 1.0))
