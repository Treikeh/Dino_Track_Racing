extends RigidBody3D
class_name CarController


## How much acceleration is applied at different speeds (speed is in khm)
@export var _accel_curve: Curve
@export var _turn_curve: Curve
@export var _ground_check: ShapeCast3D

@export_group("Visuals")
@export var _mesh_lerp_speed: float = 10.0
@export var _mesh: Node3D

var throttle: float
var turn_input: float
var turn_dir: float
var speed_khm: float

@onready var _default_linear_damp: float = linear_damp
#@onready var _default_angular_damp: float = angular_damp


func _process(delta: float) -> void:
	# Tilt mesh left/right when turning
	var x_dir_dot: float = global_basis.x.dot(linear_velocity)
	_mesh.rotation_degrees.z = lerpf(_mesh.rotation_degrees.z, x_dir_dot, _mesh_lerp_speed * delta)
	
	# Tilt mesh forward/backwards based on which direction the player is driving
	var z_dir_dot: float = -global_basis.z.dot(linear_velocity)
	_mesh.rotation_degrees.x = lerpf(_mesh.rotation_degrees.x, z_dir_dot * 0.5, _mesh_lerp_speed * delta)
	
	# Reverse turn direction when driving backwards
	turn_dir = turn_input * -1.0 if throttle < 0.0 else turn_input


func _physics_process(_delta: float) -> void:
	speed_khm = linear_velocity.length() * 3.6
	if _ground_check.is_colliding():
		linear_damp = _default_linear_damp
		var accel_force: float = _accel_curve.sample(speed_khm) * throttle
		apply_central_force(-global_basis.z * accel_force * mass)
		
		# Roatate car
		var turn_force: float = _turn_curve.sample(speed_khm) * turn_dir
		apply_torque(global_basis.y * turn_force * mass)
		
		# Apply a bit of stabilizing force to make the car algin with the ground normal faster
		var up_dot: float = global_basis.z.dot(_ground_check.get_collision_normal(0))
		apply_torque(global_basis.x * up_dot * 15.0)
	else:
		linear_damp = 0.0
		# Reduce how much the car can rotate in the air
		apply_torque(global_basis.y * turn_dir * 0.5 * mass)


func reset() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation = Vector3.ZERO
	global_position += Vector3.UP * 3.0
	process_mode = Node.PROCESS_MODE_INHERIT
