extends Item3D


@export var _move_speed: float = 50.0
@export var _bullet_root: Node3D
@export var _hurtbox: Hurtbox
@export var _track_follow: PathFollow3D

var _should_follow_car: bool = false
var _target_track_follow: TrackFollow
var _target_car: CarController


func _ready() -> void:
	top_level = true
	_hurtbox.set_instigator(instigator)
	
	# Get the level
	var level: Level3D = LevelManager.current_level
	
	# Attach the track follow to the track
	var local_pos: Vector3 = level._track.to_local(global_position)
	var closest_track_offset: float = level._track.curve.get_closest_offset(local_pos)
	_track_follow.reparent(level._track)
	_track_follow.progress = closest_track_offset
	
	# Get the car infront of the instigator
	var instigator_race_pos: int = level.get_race_pos_from_car(instigator)
	_target_car = level.get_car_from_race_position(instigator_race_pos - 1)
	_target_track_follow = level._track_follows[level.get_id_from_car(_target_car)]


func _physics_process(delta: float) -> void:
	# Move track follow forwards
	_track_follow.progress += _move_speed * delta
	
	# Move the bullet towards the follow target until it gets close to the target car track follow
	# then move it towards the target car
	var target_car_pos: Vector3 = _target_car.global_position
	# Track follow of the missile, not the target car
	var track_follow_pos: Vector3 = _track_follow.global_position
	
	# Check if it should follow the missiles track follow or the target car
	# Track follow of the target car, not the missile
	var car_follow_pos: Vector3 = _target_track_follow.global_position
	# Distance between the missiles track follow and the target cars track follow
	var follow_distance: float = _bullet_root.global_position.distance_squared_to(car_follow_pos)
	if not _should_follow_car:
		_should_follow_car = follow_distance < 50.0
	
	# Get the target the missile should move to and the speed at which it should move
	var lerp_speed: float = 20.0 if _should_follow_car else 15.0
	var lerp_target: Vector3 = target_car_pos if _should_follow_car else track_follow_pos
	# Move bullet towards lerp target
	_bullet_root.global_position = lerp(_bullet_root.global_position, lerp_target, lerp_speed * delta)
	_bullet_root.look_at(lerp_target)


func _hit_target() -> void:
	queue_free()
	_track_follow.queue_free()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	_hit_target()


func _on_lifetime_timeout() -> void:
	_hit_target()
