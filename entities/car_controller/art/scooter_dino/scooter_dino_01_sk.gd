extends Node3D


@export var _anim_tree: AnimationTree

var is_screaming: bool = false
var turn_input: float = 0.0


func _process(_delta: float) -> void:
	_anim_tree.set("parameters/turning/blend_position", turn_input)
	_anim_tree.set("parameters/scream_blend/blend_amount", 1.0 if is_screaming else 0.0)
