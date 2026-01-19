extends Control


signal menu_closed(menu: Control)


## Which node to grab focus when the menu is opened
@export var _open_focus: Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close_menu()


# Reset menu when opening it
func open_menu() -> void:
	_open_focus.grab_focus()


func close_menu() -> void:
	menu_closed.emit(self)


func _on_close_button_pressed() -> void:
	close_menu()
