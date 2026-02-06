extends Node
class_name EnemyCpuController


#var visual: Node3D

var _can_drift: bool = true
var _is_drifting: bool = false
var _drift_time: float = 0.0
var _drift_cooldown: float = 0.0

var _car_controller: CarController
var _track_follow: TrackFollow
var _use_item_timer: Timer

@onready var _track: Path3D = _track_follow.get_parent()
@onready var _track_curve: Curve3D = _track.curve


func _init(car_controller: CarController, track_follow: TrackFollow) -> void:
	_car_controller = car_controller
	_track_follow = track_follow


func _ready() -> void:
	#visual = MeshInstance3D.new()
	#LevelManager.add_child(visual)
	#visual.mesh = BoxMesh.new()
	
	_use_item_timer = Timer.new()
	add_child(_use_item_timer)
	
	_use_item_timer.wait_time = 1.0
	_use_item_timer.one_shot = false
	
	_use_item_timer.timeout.connect(_use_item)
	_use_item_timer.start()


func _process(_delta: float) -> void:
	var offset_pos: Vector3 = _track_curve.sample_baked(_track_follow.progress + 10.0)
	#visual.global_position = offset_pos
	
	var turn_dir: float = -_car_controller.global_basis.x.dot(_car_controller.global_position.direction_to(offset_pos))
	_car_controller.turn_input = turn_dir
	_car_controller.throttle = 1.0
	
	
	if not _can_drift:
		_drift_cooldown += _delta
		if _drift_cooldown >= 3.0:
			_can_drift = true
			_drift_cooldown = 0.0
	
	if _is_drifting:
		_drift_time += _delta
	
	if abs(turn_dir) > 0.65 and not _is_drifting and _can_drift:
		_is_drifting = true
		_can_drift = false
		_car_controller.try_dirft()
		_drift_time = 0.0
	elif _is_drifting and _drift_time >= 1.25:
		_is_drifting = false
		_car_controller.release_drift()


func _use_item() -> void:
	var tmp: int = randi_range(0, 10)
	if _car_controller._held_item and tmp == 1:
		_car_controller.use_held_item()
