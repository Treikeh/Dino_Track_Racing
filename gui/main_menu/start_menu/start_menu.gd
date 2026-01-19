extends Control


signal menu_button_pressed(menu_id: int)


@export var _start_button: Button
@export var _version_label: Label


func _ready() -> void:
	_start_button.grab_focus.call_deferred()
	_version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")


func open_menu() -> void:
	_start_button.grab_focus()


func _on_play_button_pressed() -> void:
	menu_button_pressed.emit(1)


func _on_controls_button_pressed() -> void:
	menu_button_pressed.emit(2)


func _on_options_button_pressed() -> void:
	menu_button_pressed.emit(3)


func _on_credits_button_pressed() -> void:
	menu_button_pressed.emit(4)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
