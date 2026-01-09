extends CanvasLayer


@export var _leaderboard: Control
@export var _pause_menu: Control


func _ready() -> void:
	_leaderboard.hide()
	_pause_menu.hide()


func _unhandled_input(event: InputEvent) -> void:
	# Pause game when pressing ESC or Options (on controller)
	if event.is_action_pressed("pause"):
		_pause_menu.pause_game()


func on_race_ended() -> void:
	await get_tree().create_timer(2.5).timeout
	_leaderboard.show()
	_leaderboard.populate()
