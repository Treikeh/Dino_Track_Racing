extends Control


signal start_pressed


@export var _start_button: Button
@export var _version_label: Label


func _ready() -> void:
	_start_button.grab_focus.call_deferred()
	_version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")


func _on_play_button_pressed() -> void:
	start_pressed.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
