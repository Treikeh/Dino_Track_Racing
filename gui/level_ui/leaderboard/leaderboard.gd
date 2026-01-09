extends Control


@export var _entry_container: Container
@export var _start_focus_object: Control


# Add all the entires to the leaderboard
func populate() -> void:
	_start_focus_object.grab_focus()
	
	var players: Array[int] = Globals.players.keys()
	players.sort_custom(_sort_player_time_taken)
	
	for i: int in players.size():
		# Get info about the player
		var id: int = players[i]
		#TODO: Convert to minutes form seconds
		var time_taken: float = Globals.players[id]
		
		# Add label to the leaderboard
		var entry_label := Label.new()
		_entry_container.add_child(entry_label)
		entry_label.text = "Player %s: ------- %s" % [id + 1, _time_convert(time_taken)]


func _sort_player_time_taken(a: int, b: int) -> bool:
	return Globals.players[a] < Globals.players[b]


func _time_convert(time_in_sec: float) -> String:
	var seconds: int = floori(time_in_sec) % 60
	@warning_ignore("integer_division")
	var minutes: int = (seconds / 60) % 60
	@warning_ignore("integer_division")
	var hours: int = (seconds / 60) / 60
	var decimal: float = (time_in_sec - seconds) * 100
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, floori(decimal)]


func _on_replay_button_pressed() -> void:
	LevelManager.load_level(LevelManager.current_level_path)


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
