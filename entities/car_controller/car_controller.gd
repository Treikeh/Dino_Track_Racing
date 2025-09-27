extends RigidBody3D
class_name CarController


@export var _move_speed: float = 15.0
@export var _turn_speed: float = 0.75


var throttle: float
var turn_dir: float


func _physics_process(_delta: float) -> void:
	apply_central_force(-global_basis.z * throttle * _move_speed)
	apply_torque(global_basis.y * turn_dir * _turn_speed)


func reset() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation = Vector3.ZERO
	global_position += Vector3.UP * 3.0
	process_mode = Node.PROCESS_MODE_INHERIT
