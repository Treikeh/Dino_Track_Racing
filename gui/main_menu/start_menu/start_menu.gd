extends Control


signal menu_button_pressed(menu_id: int)

@export var _button_move_distance: float = 500.0
@export var _move_in_out_duration: float = 0.5
@export var _start_button: Button
@export var _title_label: Label
@export var _version_label: Label
@export var _bottom_container: Container
@export var _buttons_container: Container

var _title_start_position: Vector2
var _bottom_start_position: Vector2
var _start_buttons_positions: Array[Vector2]
var _close_timer: Timer


func _ready() -> void:
	_start_button.grab_focus.call_deferred()
	_version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	
	# Save the start positions of all the buttons
	for button: Button in _buttons_container.get_children():
		_start_buttons_positions.append(button.position)
	
	_title_start_position = _title_label.position
	_bottom_start_position = _bottom_container.position
	
	_close_timer = Timer.new()
	add_child(_close_timer)
	
	open_menu()


func open_menu() -> void:
	_start_button.grab_focus()
	$AudioStreamPlayer.play()
	
	# Wait until the frame has finished processing to make the tween work properly
	await get_tree().process_frame
	
	# Move buttons into the screen
	for i: int in _buttons_container.get_child_count():
		var button: Button = _buttons_container.get_child(i)
		button.position.x = _start_buttons_positions[i].x - 500.0
		
		var _tween: Tween = create_tween()
		_tween.set_ease(Tween.EASE_OUT)
		_tween.set_trans(Tween.TRANS_BACK)
		_tween.tween_interval(i * 0.05)
		_tween.tween_property(
				button,
				"position:x",
				button.position.x + _button_move_distance,
				_move_in_out_duration
		)
	
	_title_label.position.y = _title_start_position.y - 250.0
	var title_tween: Tween = create_tween()
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.tween_property(
			_title_label,
			"position:y",
			_title_label.position.y + 250.0,
			_move_in_out_duration
	)
	
	_bottom_container.position.y = _bottom_start_position.y + 50.0
	var bottom_tween: Tween = create_tween()
	bottom_tween.set_ease(Tween.EASE_OUT)
	bottom_tween.set_trans(Tween.TRANS_BACK)
	bottom_tween.tween_property(
			_bottom_container,
			"position:y",
			_bottom_container.position.y - 50.0,
			_move_in_out_duration
	)
	
	# Stop menu from being disabled when opening the menu
	if not _close_timer.is_stopped():
		_close_timer.stop()


func close_menu(new_menu: int = 0) -> void:
	menu_button_pressed.emit(new_menu)
	
	# Move buttons out of screen
	var child_count: int = _buttons_container.get_child_count()
	for i: int in child_count:
		var button: Button = _buttons_container.get_child(i)
		
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_interval(i * 0.05)
		tween.tween_property(
				button,
				"position:x",
				button.position.x - _button_move_distance,
				_move_in_out_duration
		)
	
	var title_tween: Tween = create_tween()
	title_tween.set_ease(Tween.EASE_IN)
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.tween_property(
			_title_label,
			"position:y",
			_title_label.position.y - 250.0,
			_move_in_out_duration
	)
	
	var bottom_tween: Tween = create_tween()
	bottom_tween.set_ease(Tween.EASE_IN)
	bottom_tween.set_trans(Tween.TRANS_BACK)
	bottom_tween.tween_property(
			_bottom_container,
			"position:y",
			_bottom_container.position.y + 50.0,
			_move_in_out_duration
	)
	
	# Start timer to disable menu
	if not _close_timer.is_stopped():
		_close_timer.stop()
	_close_timer.start(_move_in_out_duration + (child_count * 0.05))
	
	# Disable menu after tweens have finished
	await _close_timer.timeout
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_play_button_pressed() -> void:
	close_menu(1)


func _on_controls_button_pressed() -> void:
	close_menu(2)


func _on_options_button_pressed() -> void:
	close_menu(3)


func _on_credits_button_pressed() -> void:
	close_menu(4)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
