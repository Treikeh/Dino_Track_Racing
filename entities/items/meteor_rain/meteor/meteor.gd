extends CharacterBody3D
class_name Meteor


@export var _move_speed: float = 67.5
@export var _hurtbox: Hurtbox

var _target_position: Vector3
var _instigator: CarController


func with_data(instigator: CarController, target_position: Vector3) -> Meteor:
	_instigator = instigator
	_target_position = target_position
	return self


func _ready() -> void:
	_hurtbox.set_instigator(_instigator)
	
	const R: float = 5.0
	var rand_pos: Vector3 = Vector3(randf_range(-R, R), randf_range(-R, R), randf_range(-R, R))
	global_position = _target_position + (Vector3.UP * 25.0) + rand_pos
	
	var move_dir: Vector3 = global_position.direction_to(_target_position)
	velocity = move_dir * _move_speed


func _physics_process(_delta: float) -> void:
	#if is_on_wall():
	#	queue_free()
	
	move_and_slide()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
