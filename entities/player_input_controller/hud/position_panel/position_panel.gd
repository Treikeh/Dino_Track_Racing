extends PanelContainer


@export var _race_pos_label: Label
@export var _lap_label: Label


func update_race_pos(race_pos: int) -> void:
	# Turn position into a string
	var car_pos_string: String = str(race_pos)
	# Change the car pos string to match the fonts values if in 1 - 3 place
	# See positions font image and the ASCII character codes positions (48 - 60)
	match race_pos:
		1:
			car_pos_string = ":"
		2:
			car_pos_string = ";"
		3:
			car_pos_string = "<"
	# Set position label text
	_race_pos_label.text = car_pos_string


func update_lap_label(lap: int, total_laps: int) -> void:
	_lap_label.text = "%s/%s" % [lap, total_laps]
