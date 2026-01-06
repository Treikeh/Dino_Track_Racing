extends CanvasLayer
class_name LoadingScreen


signal fully_visible


const FADE_DURATION: float = 0.5

@export var _control_root: Control


func _ready() -> void:
	_control_root.hide()


func fade_in() -> void:
	# Reset control node when showing the loading screen
	_control_root.modulate = Color.TRANSPARENT
	_control_root.show()
	
	# Make the loading screen visible
	var tween: Tween = create_tween()
	tween.tween_property(_control_root, "modulate", Color.WHITE, FADE_DURATION)
	
	await tween.finished
	fully_visible.emit()


func fade_out() -> void:
	# Make loading screen transparent
	var tween: Tween = create_tween()
	tween.tween_property(_control_root, "modulate", Color.TRANSPARENT, FADE_DURATION)
	
	# Hide loading screen when fully transparent
	await tween.finished
	_control_root.hide()
