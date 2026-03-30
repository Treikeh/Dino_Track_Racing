extends Control


signal menu_closed(menu: Control)


@export var _start_focus: Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_menu()


func open_menu() -> void:
	# Show and enable the menu
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
	_start_focus.grab_focus()


func close_menu() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	menu_closed.emit(self)




func _on_level_button_pressed(source: BaseButton) -> void:
	var level: String = source.name.trim_suffix("Button")
	LevelManager.load_level("res://levels/%s/%s.tscn" % [level, level.to_lower()])
