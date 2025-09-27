extends RigidBody3D
class_name CarController


@export var _move_speed: float = 15.0
@export var _turn_speed: float = 0.75


var throttle: float
var turn_dir: float


func _physics_process(_delta: float) -> void:
	apply_central_force(-global_basis.z * throttle * _move_speed)
	apply_torque(global_basis.y * turn_dir * _turn_speed)
