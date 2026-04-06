extends Control


signal show_level_select_menu


const ENTRY_SCENE: PackedScene = preload("res://gui/level_ui/leaderboard/leaderboard_entry/leaderboard_entry.tscn")


@export var _entry_container: Container
@export var _start_focus_object: Control
@export var _replay_button: Button
@export var _main_menu_button: Button


var show_total_time_taken: bool = false


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
	return Globals.players[a].time_taken < Globals.players[b].time_taken


func populate_total() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_start_focus_object.grab_focus()
	
	#_finished_cars = finished_cars
	#var players: Array[int] = _finished_cars.keys()
	var players: Array[int] = Globals.players.keys()
	players.sort_custom(_sort_player_total_time_taken)
	
	for i: int in players.size():
		# Get info about the player
		var id: int = players[i]
		#var time_taken: float = _finished_cars[id]
		var time_taken: float = Globals.players[id].total_time_taken
		print(Globals.players[id].total_time_taken)
		
		_add_entry.call_deferred(i, id, time_taken)


func _sort_player_total_time_taken(a: int, b: int) -> bool:
	return Globals.players[a].total_time_taken < Globals.players[b].total_time_taken


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
	if Globals.races_completed == 1:
		show_level_select_menu.emit()
		return
	
	if show_total_time_taken == true:
		show_level_select_menu.emit()
	else:
		show_total_time_taken = true
		# Show total time taken leaderboard
		for child: Node in _entry_container.get_children():
			_entry_container.remove_child(child)
			child.queue_free()
		populate_total()
		# Hide next button when all races have been completed
		if Globals.races_completed >= Globals.max_races:
			_replay_button.hide()
			_main_menu_button.grab_focus()


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
