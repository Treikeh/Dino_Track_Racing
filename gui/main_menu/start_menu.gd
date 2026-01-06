extends Control


signal start_pressed


@export var _start_button: Button


func _ready() -> void:
	_start_button.grab_focus.call_deferred()


func _on_play_button_pressed() -> void:
	start_pressed.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
