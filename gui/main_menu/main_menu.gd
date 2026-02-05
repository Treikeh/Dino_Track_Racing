extends Control


@export var _menu_root: Control
@export var _start_menu: Control


func _ready() -> void:
	Globals.set_allow_cursor(true)
	
	# Disable all child menus
	for child: Node in _menu_root.get_children():
		if child != _start_menu:
			_disable_menu(child)
	
	# Renable the start menu
	_enable_menu(_start_menu)


func _enable_menu(menu: Control) -> void:
	menu.show()
	menu.process_mode = Node.PROCESS_MODE_INHERIT
	if menu.has_method("open_menu"):
		menu.open_menu()


func _disable_menu(_menu: Control) -> void:
	pass
	#menu.hide()
	#menu.process_mode = Node.PROCESS_MODE_DISABLED


#region Signals

func _on_start_menu_menu_button_pressed(menu_id: int) -> void:
	var new_menu: Control = _menu_root.get_child(menu_id)
	_disable_menu(_start_menu)
	_enable_menu(new_menu)


func _on_menu_closed(menu: Control) -> void:
	_enable_menu(_start_menu)
	_disable_menu(menu)

#endregion
