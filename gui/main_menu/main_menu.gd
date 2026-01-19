extends Control


@export var _start_menu: Control
@export var _player_join_menu: Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_enable_menu(_start_menu)
	_disable_menu(_player_join_menu)


func _on_start_menu_start_pressed() -> void:
	_enable_menu(_player_join_menu)
	_disable_menu(_start_menu)


func _enable_menu(menu: Control) -> void:
	menu.show()
	menu.process_mode = Node.PROCESS_MODE_INHERIT


func _disable_menu(menu: Control) -> void:
	menu.hide()
	menu.process_mode = Node.PROCESS_MODE_DISABLED
