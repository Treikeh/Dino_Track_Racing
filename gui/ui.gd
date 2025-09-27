extends CanvasLayer


signal return_to_main_menu
signal player_button_pressed(player_count: int)


@export var _main_menu: Control
@export var _pause: Control
# Nodes to grab focus when entering the different menus
@export var _main_menu_focus: Control
@export var _pause_focus: Control


func _ready() -> void:
	_main_menu_focus.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _main_menu.visible:
		get_tree().paused = true
		_pause.show()
		_pause_focus.grab_focus()


func _on_player_button_pressed(source: BaseButton) -> void:
	player_button_pressed.emit(source.get_index() + 1)
	_main_menu.hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	_pause.hide()
	_main_menu.show()
	_main_menu_focus.grab_focus()
	return_to_main_menu.emit()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	_pause.hide()
