extends Control


@export var _entry_container: Container


# Add all the entires to the leaderboard
func populate() -> void:
	#TODO: Sort list so that the fastest player is at the top
	for i: int in Globals.players.size():
		# Get info about the player
		var id: int = Globals.players.keys()[i]
		#TODO: Convert to minutes form seconds
		var time_taken: float = Globals.players[id]
		
		# Add label to the leaderboard
		var entry_label := Label.new()
		_entry_container.add_child(entry_label)
		entry_label.text = "Player %s: ------- %s" % [id + 1, _time_convert(time_taken)]


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")


func _time_convert(time_in_sec: float) -> String:
	var seconds: int = floori(time_in_sec) % 60
	@warning_ignore("integer_division")
	var minutes: int = (seconds / 60) % 60
	@warning_ignore("integer_division")
	var hours: int = (seconds / 60) / 60
	var decimal: float = (time_in_sec - seconds) * 100
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, floori(decimal)]
