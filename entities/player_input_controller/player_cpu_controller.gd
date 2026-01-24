extends Node
class_name PlayerCpuController


var _car_controller: CarController
var _track_follow: TrackFollow

var visual: Node3D

@onready var _track: Path3D = _track_follow.get_parent()
@onready var _track_curve: Curve3D = _track.curve


func _init(car_controller: CarController, track_follow: TrackFollow) -> void:
	_car_controller = car_controller
	_track_follow = track_follow


func _ready() -> void:
	visual = MeshInstance3D.new()
	LevelManager.add_child(visual)
	visual.mesh = BoxMesh.new()


func _process(_delta: float) -> void:
	var offset_pos: Vector3 = _track_curve.sample_baked(_track_follow.progress + 10.0)
	visual.global_position = offset_pos
	
	var turn_dir: float = -_car_controller.global_basis.x.dot(_car_controller.global_position.direction_to(offset_pos))
	_car_controller.turn_input = turn_dir
	_car_controller.throttle = 1.0
	
