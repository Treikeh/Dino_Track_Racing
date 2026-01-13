extends RigidBody3D
class_name CarController


signal item_picked_up(item: ItemResource)
signal trick_performed
signal trick_boost_started
signal trick_boost_ended
signal took_damage


enum MovementState {
	NORMAL,
	DISABLED,
	SPIN_OUT,
}

enum TrickState {
	CAN_PERFORM,
	WINDOW_PASSED,
	PERFORMED,
	BOOSTING,
}


@export var _max_turn_angle: float = 27.0
@export var _rot_speed: float = 8.0
## How much acceleration is applied at different speeds (speed is in kmh). Y axis is speed
@export var _accel_curve: Curve
## How well the car will be able to turn at different speeds (speed is in kmh). Y axis is speed
@export var _turn_curve: Curve
@export var _drive_dir: Node3D
@export var _ground_check: RayCast3D

@export_group("Suspension")
@export var _rest_height: float = 0.65
@export var _spring_force: float = 100.0
@export var _spring_damping: float = 15.0

@export_group("Drifting")
@export var _min_drift_angle: float = 10.0
@export var _max_drift_angle: float = 35.0
# How much force to apply sideways when drifting
@export var _sideways_dirft_force: float = 65.0
# How long the car has to drift before getting a boost
@export var _min_drift_boost_duration: float = 1.0
var _is_drifting: bool = false
# Which direction the car is drifting in (1 = left, -1 right)
var _drift_dir: int = 0
# How long the car has been drifting for
var _drift_time: float = 0.0

@export_group("Tricking")
## How long the player can has to press the trick button after leaving the ground
@export var _trick_window_duration: float = 0.2
## The curve used to apply trick boost speed. Y axis is time
@export var _trick_boost_curve: Curve
var _trick_window_time: float = 0.0
var _trick_boost: float = 0.0
var _trick_boost_time: float = 0.0
var _trick_state: TrickState = TrickState.CAN_PERFORM

@export_group("Damage")
@export var _spin_out_duration: float = 2.0
## How many times the car controller should rotate 360 deg after getting hit
@export var _spin_out_revolutions: float = 4.0

@export_group("Art")
@export var _mesh_lerp_speed: float = 10.0
@export var _mesh: Node3D

var throttle: float
var turn_input: float
var speed_khm: float

var _movement_state: MovementState = MovementState.NORMAL
var _turn_dir: float
##NOTE: This is reversed. When it's is 1.0 there is no drift
var _ground_normal: Vector3
var _held_item: ItemResource

@onready var _default_linear_damp: float = linear_damp
@onready var _default_angular_damp: float = angular_damp


func _ready() -> void:
	_ground_check.target_position.y = -(_rest_height + 0.1)


func _process(delta: float) -> void:
	_rotate_mesh(delta)
	
	# Reverse turn direction when driving backwards
	_turn_dir = turn_input * -1.0 if throttle < 0.0 else turn_input
	# Rotate drive dir based on input
	if _is_drifting:
		# Angle between min and max drift angle. Also the angle to use when not turning
		var center_angle: float = (_min_drift_angle + _max_drift_angle) * 0.5
		# Difference between center angle and min/max angle.
		# How much that can be added/subtracted from center angle while still being within min/max angle
		var angle_diff: float = center_angle - _min_drift_angle
		# How much to add/subtract from center angle when turning
		var drift_turn_input: float = angle_diff * _drift_dir * turn_input
		# Apply drift rotation
		_drive_dir.rotation_degrees.y = (center_angle + drift_turn_input) * _drift_dir
	else:
		# Normal turning
		_drive_dir.rotation_degrees.y = _max_turn_angle * turn_input * _turn_curve.sample(speed_khm)
	
	# Respawn
	if (global_position.y < -100.0):
		global_position = Vector3(0.0, 2.0, 0.0)
		linear_velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	speed_khm = linear_velocity.length() * 3.6
	if _ground_check.is_colliding():
		_ground_normal = _ground_check.get_collision_normal()
		linear_damp = _default_linear_damp
		
		# Only allow input movement when the movement state is normal
		if _movement_state == MovementState.NORMAL:
			# Move car
			var accel_force: float = _accel_curve.sample(speed_khm) * throttle
			apply_central_force(-_drive_dir.global_basis.z * (accel_force + _trick_boost) * mass)
			
			# Drifting
			if _is_drifting:
				# Increase drift duration
				apply_central_force(_drive_dir.global_basis.x * _sideways_dirft_force * _drift_dir * mass)
				_drift_time += delta
				#TODO: Show drift vfx when drift duration >= min drift boost duration
				# Stop drift if speed gets too low
				if speed_khm <= 5.0:
					stop_drift()
			
			# Roatate car
			# Dot product of forwards and the velocity
			var forward_vel_dot: float = -global_basis.z.dot(linear_velocity.normalized())
			# How much to mult turn force based on which direction the car wants to drive in
			var turn_force_mult: float = -global_basis.z.dot(_drive_dir.global_basis.x)
			var turn_force: float = turn_force_mult * _rot_speed * forward_vel_dot
			apply_torque(global_basis.y * turn_force * mass)
			
			# Trick states
			match _trick_state:
				TrickState.PERFORMED:
					_start_trick_boost()
				TrickState.BOOSTING:
					_apply_trick_boost(delta)
				_:
					_stop_trick_boost()
		
		_apply_suspension()
		_apply_anti_roll()
		_apply_anti_slip(delta)
	else:
		linear_damp = 0.0
		# Reduce how much the car can rotate in the air
		apply_torque(global_basis.y * _turn_dir * 0.5 * mass)
		
		# Stop trick boost if the player is in the air
		if _trick_state == TrickState.BOOSTING:
			_stop_trick_boost()
		
		# Reduce trick window
		_trick_window_time += delta
		# Don't allow tricking after the trick window duration has passed
		if _trick_state == TrickState.CAN_PERFORM and _trick_window_time >= _trick_window_duration:
			_trick_state = TrickState.WINDOW_PASSED


# Make the car float above the ground so that it can drive over small edges and bumps without issues
func _apply_suspension() -> void:
	var collision_point: Vector3 = _ground_check.get_collision_point()
	var hit_distance: float = global_position.distance_to(collision_point)
	var normal_vel: float = -_ground_normal.dot(linear_velocity)
	var dispalcement: float = _rest_height - hit_distance
	var force: float = (_spring_force * -dispalcement) - (normal_vel * _spring_damping)
	apply_central_force(-_ground_normal * force * mass)

# Make the car not slip sideways
func _apply_anti_slip(delta: float) -> void:
	const ANI_SLIP_FORCE: float = 0.125
	var slip_dir: Vector3 = global_basis.x
	var slip_vel: float = linear_velocity.dot(slip_dir)
	var force: float = -(slip_vel * ANI_SLIP_FORCE) / delta
	
	apply_central_force(slip_dir * force * mass)


# Apply a bit of stabilizing force to make the car align with the ground normal
func _apply_anti_roll() -> void:
	var up_dot: float = global_basis.z.dot(_ground_check.get_collision_normal())
	var left_dot: float = global_basis.x.dot(_ground_check.get_collision_normal())
	var stabilize_vector: Vector3 = (global_basis.x * up_dot) + (-global_basis.z * left_dot)
	apply_torque(stabilize_vector * 15.0)


func _rotate_mesh(delta: float) -> void:
	# Tilt mesh left/right when turning
	var x_dir_dot: float = global_basis.x.dot(linear_velocity)
	_mesh.rotation_degrees.z = lerpf(_mesh.rotation_degrees.z, x_dir_dot * 1.0, _mesh_lerp_speed * delta)
	
	# Tilt mesh forward/backwards based on which direction the player is driving
	var z_dir_dot: float = -global_basis.z.dot(linear_velocity)
	_mesh.rotation_degrees.x = lerpf(_mesh.rotation_degrees.x, z_dir_dot * 0.1, _mesh_lerp_speed * delta)


func set_movement_state(new_state: MovementState) -> void:
	_movement_state = new_state


#region Drifting

func try_dirft() -> void:
	# Only allow drift to start when on the ground and when turning
	if _ground_check.is_colliding() and abs(turn_input) > 0.5:
		_is_drifting = true
		_drift_time = 0.0
		_drift_dir = 1 if turn_input > 0.0 else -1
	# Perform trick in the air if drifting is pressed
	elif not _ground_check.is_colliding() and _trick_state == TrickState.CAN_PERFORM:
		_trick_state = TrickState.PERFORMED
		trick_performed.emit()


func release_drift() -> void:
	if _is_drifting:
		stop_drift()
		if _drift_time >= _min_drift_boost_duration:
			_start_trick_boost()


func stop_drift() -> void:
	_is_drifting = false
	_drift_dir = 0

#endregion


#region Tricking

func _start_trick_boost() -> void:
	_trick_boost_time = 0.0
	_trick_state = TrickState.BOOSTING
	trick_boost_started.emit()


func _apply_trick_boost(delta: float) -> void:
	_trick_boost_time += delta
	# Get how much the boost should be based on the trick boost curve
	_trick_boost = _trick_boost_curve.sample(_trick_boost_time)
	# Stop trick boost after it has boosted for the length of the curve
	if _trick_boost_time >= _trick_boost_curve.max_domain:
		_stop_trick_boost()


func _stop_trick_boost() -> void:
	# Reset trick window
	_trick_window_time = 0.0
	# Reset trick boost
	_trick_boost = 0.0
	# Allow new tricks to be made
	_trick_state = TrickState.CAN_PERFORM
	trick_boost_ended.emit()

#endregion


#region Items

func pick_up_item(item: ItemResource) -> void:
	if not _held_item:
		_held_item = item
		item_picked_up.emit(item)


func use_held_item() -> void:
	if _held_item:
		var item: Item3D = _held_item.scene.instantiate().with_data(self)
		add_child(item)
		item.top_level = true
		_held_item = null

#endregion


#region Damage

func _on_hitbox_hit() -> void:
	stop_drift()
	set_movement_state(MovementState.SPIN_OUT)
	linear_damp *= 0.25
	angular_damp *= 0.5
	took_damage.emit()
	
	# Spin mesh
	#NOTE: Could be replaced with an animation
	_mesh.rotation_degrees.y = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(_mesh, "rotation_degrees:y", 360.0 * _spin_out_revolutions, _spin_out_duration)


func _on_hitbox_invulnerability_ended() -> void:
	set_movement_state(MovementState.NORMAL)
	linear_damp = _default_linear_damp
	angular_damp = _default_angular_damp

#endregion
