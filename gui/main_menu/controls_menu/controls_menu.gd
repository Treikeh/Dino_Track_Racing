extends Control


signal menu_closed(menu: Control)


const TWEEN_DURATION: float = 0.5

@export var _panel: Control
@export var _button_display: Control
@export var _current_tab_container: HBoxContainer
@export var _selected_tab_texture: Texture2D
@export var _unselected_tab_texture: Texture2D
@export var _tabs: Array[Control] = []

var _tab_index: int = 0
var _panel_start_pos: Vector2
var _button_dispaly_start_pos: Vector2


func _ready() -> void:
	# Save default positions so that they can be used later when opening the menu
	_panel_start_pos = _panel.position
	_button_dispaly_start_pos = _button_display.position
	
	# Move the menu items outside of the screen
	_panel.position.x = size.x
	_button_display.position.y = size.y


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_go_to_next_tab()
	
	if event.is_action_pressed("ui_cancel"):
		_go_to_prev_tab()


func open_menu() -> void:
	# Show and enable the menu
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
	
	# Hide all panels exepct for the first one
	for i: int in _tabs.size():
		_tabs[i].visible = i == 0
	
	# Add a small delay before closing the menu to avoid overlap with the main menu
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	AudioWorldUi.play_sound(SfxUI.Type.SWOOSH, 1.1)
	
	# Move the menu panel into the screen
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.tween_property(_panel, "position", _panel_start_pos, TWEEN_DURATION)
	
	# Move the button dispaly into the screen
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.set_ease(Tween.EASE_OUT)
	button_dispaly_tween.tween_property(
			_button_display,
			"position",
			_button_dispaly_start_pos,
			TWEEN_DURATION
	)
	
	_update_current_tab_label()


func close_menu() -> void:
	AudioWorldUi.play_sound(SfxUI.Type.SWOOSH, 0.8)
	
	# Tween the panel to the right
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_IN)
	panel_tween.tween_property(_panel, "position:x", size.x, TWEEN_DURATION)
	
	# Tween the button down
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.tween_property(_button_display, "position:y", size.y, TWEEN_DURATION)
	
	# Add a small delay before closing the menu to avoid overlap with the main menu
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	menu_closed.emit(self)
	
	# Wait until the tween has finished to disabled the menu
	await get_tree().create_timer(TWEEN_DURATION).timeout
	
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _go_to_next_tab() -> void:
	# Increase current tab if not at the last tab
	var desired_tab: int = _tab_index + 1
	if desired_tab < _tabs.size():
		_show_right_tab()
		_tab_index += 1
		_update_current_tab_label()


func _go_to_prev_tab() -> void:
	# Decrease current tab if not at the first tab
	var desired_tab: int = _tab_index - 1
	if desired_tab > -1:
		_show_left_tab()
		_tab_index -= 1
		_update_current_tab_label()
	# Colse the menu if trying to go back when on the last tab
	elif desired_tab <= 0:
		close_menu()


func _show_right_tab() -> void:
	# Get current and next tab
	var current_tab: Control = _tabs[_tab_index]
	var next_tab: Control = _tabs[_tab_index + 1]
	
	# Move the next tab to the left of the screen
	next_tab.show()
	next_tab.position.x = size.x
	
	# Move both tabs 1 screen to the left
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(current_tab, "position:x", -(size.x * 2.0), TWEEN_DURATION)
	tween.parallel().tween_property(next_tab, "position:x", 0.0, TWEEN_DURATION)
	# Hide current tab when tween finishes
	tween.tween_callback(current_tab.hide)
	
	AudioWorldUi.play_sound(SfxUI.Type.SWOOSH)


func _show_left_tab() -> void:
	# Get current and next tab
	var current_tab: Control = _tabs[_tab_index]
	var next_tab: Control = _tabs[_tab_index - 1]
	
	# Move next tab to the left of the screen
	next_tab.show()
	next_tab.position.x = -(size.x * 2.0)
	
	# Move both tabs 1 screen to the right
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(current_tab, "position:x", size.x, TWEEN_DURATION)
	tween.parallel().tween_property(next_tab, "position:x", 0.0, TWEEN_DURATION)
	# Hide current tab when tween finishes
	tween.tween_callback(current_tab.hide)
	
	AudioWorldUi.play_sound(SfxUI.Type.SWOOSH)


func _update_current_tab_label() -> void:
	for i: int in _current_tab_container.get_child_count():
		var texture_rect: TextureRect = _current_tab_container.get_child(i)
		texture_rect.texture = _selected_tab_texture if i == _tab_index else _unselected_tab_texture
		
		const NEW_TWEEN_DURATION: float = 0.2
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		if i == _tab_index:
			texture_rect.pivot_offset = texture_rect.size / 2.0
			texture_rect.rotation_degrees = 5.0
			texture_rect.scale = Vector2.ONE
			tween.tween_property(texture_rect, "rotation_degrees", 0.0, NEW_TWEEN_DURATION)
			tween.parallel().tween_property(texture_rect, "scale", Vector2.ONE * 1.15, NEW_TWEEN_DURATION)
		else:
			texture_rect.pivot_offset = texture_rect.size / 2.0
			tween.parallel().tween_property(texture_rect, "scale", Vector2.ONE, NEW_TWEEN_DURATION)
