extends Control


signal menu_closed(menu: Control)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_menu()


func close_menu() -> void:
	hide()
	menu_closed.emit(self)
	process_mode = Node.PROCESS_MODE_DISABLED
