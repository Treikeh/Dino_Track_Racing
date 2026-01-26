extends CanvasLayer


@export var _leaderboard: Control
@export var _pause_menu: Control

var _race_ended: bool = false


func _ready() -> void:
	# Hide cursor when starting the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_leaderboard.hide()
	_pause_menu.hide()


func _unhandled_input(event: InputEvent) -> void:
	# Pause game when pressing ESC or Options (on controller)
	if event.is_action_pressed("pause") and not _race_ended:
		_pause_menu.pause_game()


func on_race_ended() -> void:
	_race_ended = true
	await get_tree().create_timer(2.5).timeout
	_leaderboard.show()
	_leaderboard.populate()
