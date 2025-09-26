extends RigidBody3D
class_name CarController


var throttle: float = 0.0
var turn_dir: float = 0.0


func _physics_process(_delta: float) -> void:
	apply_central_force(-global_basis.z * throttle)
	apply_torque(global_basis.y * turn_dir)
