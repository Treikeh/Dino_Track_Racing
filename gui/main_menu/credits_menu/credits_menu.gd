extends Control


signal menu_closed(menu: Control)


const TWEEN_DURATION: float = 0.5

@export var _title: Label
@export var _panel: PanelContainer
@export var _button_display: Control

var _title_start_pos: Vector2
var _panel_start_pos: Vector2
var _button_dispaly_start_pos: Vector2


func _ready() -> void:
	_title_start_pos = _title.position
	_panel_start_pos = _panel.position
	_button_dispaly_start_pos = _button_display.position
	
	_title.position.y = -_title.size.y
	_panel.position.x = size.x
	_button_display.position.y = size.y


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_menu()


func open_menu() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
	
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	var title_tween: Tween = create_tween()
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.tween_property(_title, "position", _title_start_pos, TWEEN_DURATION)
	
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.tween_property(_panel, "position", _panel_start_pos, TWEEN_DURATION)
	
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.set_ease(Tween.EASE_OUT)
	button_dispaly_tween.tween_property(
			_button_display,
			"position",
			_button_dispaly_start_pos,
			TWEEN_DURATION
	)


func close_menu() -> void:
	$AudioStreamPlayer.play()
	var title_tween: Tween = create_tween()
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_IN)
	title_tween.tween_property(_title, "position:y", -_title.size.y, TWEEN_DURATION)
	
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_IN)
	panel_tween.tween_property(_panel, "position:x", size.x, TWEEN_DURATION)
	
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.tween_property(_button_display, "position:y", size.y, TWEEN_DURATION)
	
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	menu_closed.emit(self)
	
	await get_tree().create_timer(TWEEN_DURATION).timeout
	
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
