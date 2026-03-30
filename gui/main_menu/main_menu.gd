extends Control


@export var _menu_root: Control
@export var _start_menu: Control
@export var _player_join_menu: Control
@export var _level_select_menu: Control


func _ready() -> void:
	Globals.set_allow_cursor(true)
	
	# Renable the start menu
	_enable_menu(_start_menu)


func _enable_menu(menu: Control) -> void:
	menu.show()
	menu.process_mode = Node.PROCESS_MODE_INHERIT
	if menu.has_method("open_menu"):
		menu.open_menu()


#region Signals

func _on_start_menu_menu_button_pressed(menu_id: int) -> void:
	var new_menu: Control = _menu_root.get_child(menu_id)
	_enable_menu(new_menu)


func _on_menu_closed(_menu: Control) -> void:
	_enable_menu(_start_menu)

#endregion


func _on_player_join_menu_all_players_ready() -> void:
	_enable_menu(_level_select_menu)


func _on_level_select_menu_closed(_menu: Control) -> void:
	_enable_menu(_player_join_menu)
