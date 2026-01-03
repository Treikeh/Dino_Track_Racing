extends CanvasLayer


signal play_button_pressed(player_count: int)


@export var _main_menu: Control
@export var _pause: Control
# Nodes to grab focus when entering the different menus
@export var _pause_focus: Control
@export var _fps_label: Label

@export_group("Main Menu")
@export var _main_menu_focus: Control
@export var _player_count_label: Label
@export var _player_count_slider: HSlider


func _ready() -> void:
	_main_menu_focus.grab_focus()
	_player_count_label.text = str(int(_player_count_slider.value))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _main_menu.visible:
		get_tree().paused = true
		_pause.show()
		_pause_focus.grab_focus()


func _process(_delta: float) -> void:
	_fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


func _on_player_count_slider_value_changed(value: float) -> void:
	_player_count_label.text = str(int(value))


func _on_play_button_pressed() -> void:
	_main_menu.hide()
	play_button_pressed.emit(int(_player_count_slider.value))


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	_pause.hide()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
