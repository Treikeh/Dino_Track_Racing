extends Control


const ENTRY_SCENE: PackedScene = preload("res://gui/level_ui/leaderboard/leaderboard_entry/leaderboard_entry.tscn")


@export var _entry_container: Container
@export var _start_focus_object: Control


# Add all the entires to the leaderboard
func populate() -> void:
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
		var time_taken: float = Globals.players[id].time_taken
		
		_add_entry.call_deferred(i, id, time_taken)


func _sort_player_time_taken(a: int, b: int) -> bool:
	#return _finished_cars[a] < _finished_cars[b]
	return Globals.players[a].time_taken < Globals.players[b].time_taken


func _add_entry(index: int, id: int, time_taken: float) -> void:
	#TODO: Find a way to make the wait duration start slow and then ramp up
	const WAIT_DURATION: float = 0.1
	await get_tree().create_timer(WAIT_DURATION * index).timeout
	
	# Add an entry to the leaderboard
	var entry: LeaderboardEntry = ENTRY_SCENE.instantiate().with_data(id, time_taken)
	_entry_container.add_child(entry)
	entry.pivot_offset = entry.size / 2.0
	entry.scale = Vector2.ZERO
	entry.rotation_degrees = -5.0 if randi()&1 else 5.0
	
	# Scale the entry up
	const TWEEN_DURATION: float = 0.5
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(entry, "scale", Vector2.ONE, 0.25)
	tween.parallel().tween_property(entry, "rotation_degrees", 0.0, TWEEN_DURATION)


func _on_replay_button_pressed() -> void:
	LevelManager.load_level(LevelManager.current_level_path)


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
