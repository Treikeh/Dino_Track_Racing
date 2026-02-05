extends Control


## Which node to grab focus when pausing the game
@export var _pause_focus: Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Call deferred to stop the game from pausing immediately when unpausing
		_resume_game.call_deferred()


func pause_game() -> void:
	Globals.set_allow_cursor(true)
	show()
	get_tree().paused = true
	_pause_focus.grab_focus()


func _resume_game() -> void:
	Globals.set_allow_cursor(false)
	hide()
	get_tree().paused = false


func _on_resume_button_pressed() -> void:
	_resume_game()


func _on_restart_button_pressed() -> void:
	LevelManager.load_level(LevelManager.current_level_path)


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
