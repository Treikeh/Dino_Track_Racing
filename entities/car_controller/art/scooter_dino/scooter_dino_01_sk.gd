extends Node3D


@export var _anim_tree: AnimationTree

var is_screaming: bool = false
var drift_dir: int = 0
var turn_input: float = 0.0
var turn_angle: float = 0.0


func _process(_delta: float) -> void:
	_anim_tree.set("parameters/turning/blend_position", turn_angle)
	_anim_tree.set("parameters/scream_blend/blend_amount", 1.0 if is_screaming else 0.0)
	
	# Drift anim
	# Set if the car is drifting
	_anim_tree.set("parameters/drift_blend/blend_amount", abs(float(drift_dir)))
	# Set which direction the car is drifting in
	_anim_tree.set("parameters/drifting/blend_position", Vector2(drift_dir, turn_input * drift_dir))


func play_trick_anim() -> void:
	_anim_tree.set("parameters/trick_one_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
