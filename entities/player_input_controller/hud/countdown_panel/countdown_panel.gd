extends Control


@export var _label: Label

var default_scale: Vector2
var _countdown_tween: Tween



func _ready() -> void:
	modulate = Color.TRANSPARENT
	#pivot_offset = size / 2.0


func update_secs_left(secs_left: float) -> void:
	if secs_left <= 0:
		update_label("GO!", 2.0)
	else:
		update_label(str(int(secs_left)))


func update_label(
		new_text: String,
		visible_duration: float = 0.6,
		fade_duration: float = 0.2,
) -> void:
	# Update countdown label
	_label.text = new_text
	# Recenter the label
	_label.position = -_label.size / 2.0
	
	# Stop tween if allready running
	if _countdown_tween:
		_countdown_tween.stop()
	
	# Reset panel
	modulate = Color.TRANSPARENT
	scale = default_scale * Vector2.ONE * 2.5
	rotation_degrees = 15.0 if randi() % 2 else -15.0
	# Animate panel
	_countdown_tween = create_tween()
	_countdown_tween.set_trans(Tween.TRANS_QUAD)
	_countdown_tween.tween_property(self, "modulate", Color.WHITE, fade_duration)
	_countdown_tween.parallel().tween_property(self, "scale", default_scale, fade_duration)
	_countdown_tween.parallel().tween_property(self, "rotation_degrees", 0.0, fade_duration)
	_countdown_tween.tween_interval(visible_duration)
	_countdown_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	_countdown_tween.parallel().tween_property(self, "scale", Vector2.ZERO, fade_duration)
