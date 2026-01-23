extends PanelContainer


func update(drive_dir: float) -> void:
	var driving_wrong_way: bool = drive_dir > -0.3
	visible = not driving_wrong_way
