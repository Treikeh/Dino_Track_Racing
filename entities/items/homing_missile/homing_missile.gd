extends Item3D


@export var _track_follow_move_speed: float = 45.0
@export var _hurtbox: Hurtbox
@export var _track_follow: PathFollow3D
@export var _physics_body: CharacterBody3D

var _should_track: bool = false
var _should_follow_car: bool = false
var _move_dir: Vector3
var _target_track_follow: TrackFollow
var _target_car: CarController


func _ready() -> void:
	top_level = true
	_hurtbox.set_instigator(instigator)
	
	# Get the level
	var level: Level3D = LevelManager.current_level
	
	# Get the car infront of the instigator
	var instigator_race_pos: int = level.get_race_pos_from_car(instigator)
	_target_car = level.get_car_from_race_position(instigator_race_pos - 1)
	_target_track_follow = level._track_follows[level.get_id_from_car(_target_car)]
	
	# Attach the track follow to the track
	_track_follow.reparent(level._track)
	
	# Make homing missile go fowrad for a short moment before tracking starts
	_move_dir = -_physics_body.global_basis.z
	await get_tree().create_timer(0.2).timeout
	_should_track = true
	# Move the track follow to the closes point on the track relative to the physics body
	var local_pos: Vector3 = level._track.to_local(_physics_body.global_position)
	var closest_track_offset: float = level._track.curve.get_closest_offset(local_pos)
	_track_follow.progress = closest_track_offset


func _physics_process(delta: float) -> void:
	# Move track follow forwards
	_track_follow.progress += _track_follow_move_speed * delta
	
	if _should_track:
		# Check if it should follow the missiles track follow or the target car
		# Track follow of the target car, not the missile
		var car_follow_pos: Vector3 = _target_track_follow.global_position
		# Distance between the missiles track follow and the target cars track follow
		var follow_distance: float = _physics_body.global_position.distance_squared_to(car_follow_pos)
		if not _should_follow_car:
			_should_follow_car = follow_distance < 50.0
		
		# Move the bullet towards the follow target until it gets close to the target car track follow
		# then move it towards the target car
		var target_car_pos: Vector3 = _target_car.global_position
		# Track follow of the missile, not the target car
		var track_follow_pos: Vector3 = _track_follow.global_position
		
		var dir_to_car: Vector3 = _physics_body.global_position.direction_to(target_car_pos)
		var dir_to_follow: Vector3 = _physics_body.global_position.direction_to(track_follow_pos)
		_move_dir = dir_to_car if _should_follow_car else dir_to_follow
		var look_at_target: Vector3 = target_car_pos if _should_follow_car else track_follow_pos
	
		_physics_body.look_at(look_at_target)
	
	_physics_body.velocity = _move_dir * _track_follow_move_speed
	_physics_body.move_and_slide()


func _hit_target() -> void:
	queue_free()
	_track_follow.queue_free()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	_hit_target()


func _on_lifetime_timeout() -> void:
	_hit_target()
