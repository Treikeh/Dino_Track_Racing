extends PanelContainer
class_name LeaderboardEntry

@export var _id_label: Label
@export var _time_label: Label

@export var _tween_duration: float = 0.15
@export var _rotation: float = 10.0
@export var _focus_scale: float = 1.15

var _tween: Tween


func with_data(id: int, time: float) -> LeaderboardEntry:
	_id_label.text = "Player %s:" % (id + 1)
	_time_label.text = _time_convert(snappedf(time, 0.01))
	return self


func _time_convert(time_in_sec: float) -> String:
	var seconds: int = floori(time_in_sec) % 60
	@warning_ignore("integer_division")
	var minutes: int = (int(time_in_sec) / 60) % 60
	@warning_ignore("integer_division")
	var hours: int = (int(time_in_sec) / 60) / 60
	var decimal: float = (time_in_sec - seconds) * 100
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, floori(decimal)]


func _on_focus_entered() -> void:
	pivot_offset = size / 2.0
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
