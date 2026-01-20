extends Item3D


@export var _move_speed: float = 40.0
@export var _bullet_root: Node3D
@export var _hurtbox: Hurtbox
@export var _track_follow: PathFollow3D

var _target_car: CarController


func _ready() -> void:
	top_level = true
	_hurtbox.set_instigator(instigator)
	
	# Get the level
	var level: Level3D = LevelManager.get_child(0)
	
	# Attach the track follow to the track
	var local_pos: Vector3 = level._track.to_local(global_position)
	var closest_track_offset: float = level._track.curve.get_closest_offset(local_pos)
	_track_follow.reparent(level._track)
	_track_follow.progress = closest_track_offset
	
	# Get the car infront of the instigator
	var instigator_race_pos: int = level.get_race_pos_from_car(instigator)
	_target_car = level.get_car_from_race_position(instigator_race_pos - 1)


func _process(delta: float) -> void:
	_track_follow.progress += _move_speed * delta


func _physics_process(delta: float) -> void:
	# Move the bullet towards the follow target until it gets close to the target car then move it
	# towards the target car
	var target_car_pos: Vector3 = _target_car.global_position
	var follow_target_pos: Vector3 = _track_follow.global_position
	var target_distance: float = _bullet_root.global_position.distance_squared_to(target_car_pos)
	# Where the bullet should move to
	var lerp_target: Vector3 = follow_target_pos if target_distance > 50.0 else target_car_pos
	# Move bullet towards lerp target
	_bullet_root.global_position = lerp(_bullet_root.global_position, lerp_target, 10.0 * delta)
	_bullet_root.look_at(lerp_target)


func _hit_target() -> void:
	queue_free()
	_track_follow.queue_free()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	_hit_target()


func _on_lifetime_timeout() -> void:
	_hit_target()
