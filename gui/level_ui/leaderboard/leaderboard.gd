extends Control


@export var _entry_container: Container
@export var _start_focus_object: Control

#var _finished_cars: Dictionary[int, float]

# Add all the entires to the leaderboard
func populate(__finished_cars: Dictionary[int, float]) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_start_focus_object.grab_focus()
	
	#_finished_cars = finished_cars
	#var players: Array[int] = _finished_cars.keys()
	var players: Array[int] = Globals.players.keys()
	players.sort_custom(_sort_player_time_taken)
	
	for i: int in players.size():
		# Get info about the player
		var id: int = players[i]
		#var time_taken: float = _finished_cars[id]
		var time_taken: float = Globals.players[id]
		
		# Add label to the leaderboard
		var entry_label := Label.new()
		_entry_container.add_child(entry_label)
		entry_label.text = "Player %s: ------- %s" % [id + 1, _time_convert(snappedf(time_taken, 0.01))]


func _sort_player_time_taken(a: int, b: int) -> bool:
	#return _finished_cars[a] < _finished_cars[b]
	return Globals.players[a] < Globals.players[b]


func _time_convert(time_in_sec: float) -> String:
	var seconds: int = floori(time_in_sec) % 60
	@warning_ignore("integer_division")
	var minutes: int = (int(time_in_sec) / 60) % 60
	@warning_ignore("integer_division")
	var hours: int = (int(time_in_sec) / 60) / 60
	var decimal: float = (time_in_sec - seconds) * 100
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, floori(decimal)]


func _on_replay_button_pressed() -> void:
	LevelManager.load_level(LevelManager.current_level_path)


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
