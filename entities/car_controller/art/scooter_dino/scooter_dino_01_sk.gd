extends Node3D


@export var _anim_tree: AnimationTree

var is_screaming: bool = false
var is_grounded: bool = true
var drift_dir: int = 0
var turn_input: float = 0.0
var turn_angle: float = 0.0
var falling_speed: float = 0.0


func _process(_delta: float) -> void:
	_anim_tree.set("parameters/scream_blend/blend_amount", 1.0 if is_screaming else 0.0)
	
	# Ground
	# Set if the car is drifting
	_anim_tree.is_drifting = absi(drift_dir) >= 1
	# Turn angle
	_anim_tree.set("parameters/ground/turning/blend_position", turn_angle)
	# Drift direction and angle
	_anim_tree.set("parameters/ground/drifting/blend_position", Vector2(drift_dir, turn_input * drift_dir))
	
	# Falling
	var is_falling: bool = not is_grounded and falling_speed < -2.5
	_anim_tree.set("parameters/fall_blend/blend_amount", 1.0 if is_falling else 0.0)


func play_trick_anim() -> void:
	_anim_tree.trick_index = randi_range(0, 1)
	_anim_tree.set("parameters/trick_one_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
