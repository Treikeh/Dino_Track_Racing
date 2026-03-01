extends Node
class_name EnemyCpuController


const MIN_DRIFT_ANGLE: float = 0.4
const MAX_DRIFT_ANGLE: float = 0.8

const MIN_DRIFT_DURATION: float = 1.0
const MAX_DRIFT_DURATION: float = 1.5

const MIN_DRIFT_COOLDOWN: float = 2.0
const MAX_DRIFT_COOLDOWN: float = 4.0

const MIN_USE_ITEM_CHANCE: int = 5
const MAX_USE_ITEM_CHANCE: int = 20

const MIN_USE_ITEM_TIME: float = 1.0
const MAX_USE_ITEM_TIME: float = 2.0

#var visual: Node3D

var _can_drift: bool = false
var _is_drifting: bool = false

#NOTE: In radians
var _activate_drift_angle: float = 0.6
var _drift_duration: float = 1.25
var _drift_cooldown: float = 3.0
var _use_item_chance: int = 10
var _use_item_wait_time: float = 1.0

var _drift_time: float = 0.0
var _drift_cooldown_time: float = 0.0

var _car_controller: CarController
var _track_follow: TrackFollow
var _use_item_timer: Timer

var _hat: int = 0

@onready var _track: Path3D = _track_follow.get_parent()
@onready var _track_curve: Curve3D = _track.curve


func _init(car_controller: CarController, track_follow: TrackFollow) -> void:
	_car_controller = car_controller
	_track_follow = track_follow


func _ready() -> void:
	#visual = MeshInstance3D.new()
	#LevelManager.add_child(visual)
	#visual.mesh = BoxMesh.new()
	
	_randomize_values()
	
	_use_item_timer = Timer.new()
	add_child(_use_item_timer)
	
	_use_item_timer.wait_time = _use_item_wait_time
	_use_item_timer.one_shot = false
	
	_use_item_timer.timeout.connect(_use_item)
	_use_item_timer.start()


func _process(_delta: float) -> void:
	var offset_pos: Vector3 = _track_curve.sample_baked(_track_follow.progress + 10.0)
	#visual.global_position = offset_pos
	
	var turn_dir: float = -_car_controller.global_basis.x.dot(_car_controller.global_position.direction_to(offset_pos))
	_car_controller.turn_input = turn_dir
	_car_controller.throttle = 1.0
	
	# Drifting
	if _is_drifting:
		_drift_time += _delta
	
	if not _can_drift:
		_drift_cooldown_time += _delta
		if _drift_cooldown_time >= _drift_cooldown:
			_can_drift = true
			_drift_cooldown_time = 0.0
	
	if abs(turn_dir) > _activate_drift_angle and not _is_drifting and _can_drift:
		_is_drifting = true
		_can_drift = false
		_car_controller.try_dirft()
		_drift_time = 0.0
	elif _is_drifting and _drift_time >= _drift_duration:
		_is_drifting = false
		_car_controller.release_drift()


func _use_item() -> void:
	var chance: int = randi_range(0, 100)
	if _car_controller._held_item and chance <= _use_item_chance:
		_car_controller.use_held_item()


func _randomize_values() -> void:
	_use_item_chance = randi_range(MIN_USE_ITEM_CHANCE, MAX_USE_ITEM_CHANCE)
	_use_item_wait_time = randf_range(MIN_USE_ITEM_TIME, MAX_USE_ITEM_TIME)
	_activate_drift_angle = randf_range(MIN_DRIFT_ANGLE, MAX_DRIFT_ANGLE)
	_drift_duration = randf_range(MIN_DRIFT_DURATION, MAX_DRIFT_DURATION)
	_drift_cooldown = randf_range(MIN_DRIFT_COOLDOWN, MAX_DRIFT_COOLDOWN)
	
	_hat = randi_range(0, (_car_controller._mesh.skeleton.get_child_count() - 1))
	_car_controller._mesh.enable_hat(_hat)
