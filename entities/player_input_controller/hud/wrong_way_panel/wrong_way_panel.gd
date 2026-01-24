extends PanelContainer


func _ready() -> void:
	pivot_offset.x = size.x / 2.0


func update(drive_dir: float) -> void:
	var driving_wrong_way: bool = drive_dir > -0.3
	visible = not driving_wrong_way
