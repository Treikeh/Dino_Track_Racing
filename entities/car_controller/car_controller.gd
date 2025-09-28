extends RigidBody3D
class_name CarController


## How much acceleration is applied at different speeds (speed is in kmh)
@export var _accel_curve: Curve
## How well the car will be able to turn at different speeds (speed is in kmh)
@export var _turn_curve: Curve
@export var _ground_check: RayCast3D

@export_group("Suspension")
@export var _rest_height: float = 0.65
@export var _spring_force: float = 100.0
@export var _spring_damping: float = 15.0

@export_group("Visuals")
@export var _mesh_lerp_speed: float = 10.0
@export var _mesh: Node3D
@export var _wheels: Node3D

var throttle: float
var turn_input: float
var speed_khm: float

var _turn_dir: float
var _ground_normal

@onready var _default_linear_damp: float = linear_damp


func _ready() -> void:
	_ground_check.target_position.y = -(_rest_height + 0.1)


func _process(delta: float) -> void:
	_rotate_mesh(delta)
	
	# Reverse turn direction when driving backwards
	_turn_dir = turn_input * -1.0 if throttle < 0.0 else turn_input
	
	for wheel: RayCast3D in _wheels.get_children():
		if wheel.enable_steering:
			wheel.rotation_degrees.y = 25.0 * turn_input


func _physics_process(_delta: float) -> void:
	speed_khm = linear_velocity.length() * 3.6
	if _ground_check.is_colliding():
		_ground_normal = _ground_check.get_collision_normal()
		linear_damp = _default_linear_damp
		
		# Move car
		var accel_force: float = _accel_curve.sample(speed_khm) * throttle
		apply_central_force(-global_basis.z * accel_force * mass)
		
		# Roatate car
		var turn_force: float = _turn_curve.sample(speed_khm) * _turn_dir
		apply_torque(global_basis.y * turn_force * mass)
		
		_apply_suspension()
		_apply_anti_roll()
	else:
		linear_damp = 0.0
		# Reduce how much the car can rotate in the air
		apply_torque(global_basis.y * _turn_dir * 0.5 * mass)


# Make the car float above the ground so that it can drive over small edges and bumps without issues
func _apply_suspension() -> void:
	var hit_distance: float = (global_position - _ground_check.get_collision_point()).length()
	var normal_vel: float = -_ground_normal.dot(linear_velocity)
	var dispalcement: float = hit_distance - _rest_height
	var force: float = (_spring_force * dispalcement) - (normal_vel * _spring_damping)
	apply_central_force(-_ground_normal * force * mass)


# Apply a bit of stabilizing force to make the car align with the ground normal
func _apply_anti_roll() -> void:
	var up_dot: float = global_basis.z.dot(_ground_check.get_collision_normal())
	var left_dot: float = global_basis.x.dot(_ground_check.get_collision_normal())
	var stabilize_vector: Vector3 = (global_basis.x * up_dot) + (-global_basis.z * left_dot)
	apply_torque(stabilize_vector * 15.0)


func _apply_anti_slip() -> void:
	pass


func _rotate_mesh(delta: float) -> void:
	# Tilt mesh left/right when turning
	var x_dir_dot: float = global_basis.x.dot(linear_velocity)
	_mesh.rotation_degrees.z = lerpf(_mesh.rotation_degrees.z, x_dir_dot, _mesh_lerp_speed * delta)
	
	# Tilt mesh forward/backwards based on which direction the player is driving
	var z_dir_dot: float = -global_basis.z.dot(linear_velocity)
	_mesh.rotation_degrees.x = lerpf(_mesh.rotation_degrees.x, z_dir_dot * 0.5, _mesh_lerp_speed * delta)


func reset() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation = Vector3.ZERO
	global_position += Vector3.UP * 3.0
	process_mode = Node.PROCESS_MODE_INHERIT
