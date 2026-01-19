extends Control


signal menu_closed(menu: Control)


@export var _tab_container: TabContainer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_go_to_next_tab()
	
	if event.is_action_pressed("ui_cancel"):
		_go_to_prev_tab()


# Reset menu when opening it
func open_menu() -> void:
	_tab_container.current_tab = 0


func close_menu() -> void:
	menu_closed.emit(self)



func _go_to_next_tab() -> void:
	# Increase current tab if not at the last tab
	var desired_tab: int = _tab_container.current_tab + 1
	if desired_tab < _tab_container.get_tab_count():
		_tab_container.current_tab += 1


func _go_to_prev_tab() -> void:
	# Decrease current tab if not at the first tab
	var desired_tab: int = _tab_container.current_tab - 1
	if desired_tab > -1:
		_tab_container.current_tab -= 1
	# Colse the menu if trying to go back when on the last tab
	elif desired_tab <= 0:
		close_menu()
