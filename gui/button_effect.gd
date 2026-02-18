extends Button

@export var _tween_duration: float = 0.15
@export var _rotation: float = 10.0
@export var _focus_scale: float = 1.25
@export var _down_scale: float = 4

var _tween: Tween


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered.bind(self))
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _process(_delta: float) -> void:
	pivot_offset = size / 2


func _on_mouse_entered(source: Control) -> void:
	source.grab_focus()
	_on_focus_entered()


func _on_focus_entered() -> void:
	AudioWorldUi.play_sound(SfxUI.Type.SELECT, 1.5)
	if _tween:
		_tween.stop()
	rotation_degrees = _rotation if randi() % 2 else -_rotation
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE * _focus_scale, _tween_duration)
	_tween.parallel().tween_property(self, "rotation_degrees", 0.0, _tween_duration)


func _on_focus_exited() -> void:
	if _tween:
		_tween.stop()
	
	rotation_degrees = _rotation if randi() % 2 else -_rotation
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", Vector2.ONE, _tween_duration)
	_tween.parallel().tween_property(self, "rotation_degrees", 0.0, _tween_duration)


func _on_button_down() -> void:
	AudioWorldUi.play_sound(SfxUI.Type.PRESS, 1.25)
	if _tween:
		_tween.stop()
	
	var desired_rotation: float = _rotation if randi() % 2 else -_rotation
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE * _down_scale, _tween_duration / 2)
	_tween.parallel().tween_property(self, "rotation_degrees", desired_rotation, _tween_duration / 2)


func _on_button_up() -> void:
	if _tween:
		_tween.stop()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE * _focus_scale, _tween_duration)
	_tween.parallel().tween_property(self, "rotation_degrees", 0.0, _tween_duration)
