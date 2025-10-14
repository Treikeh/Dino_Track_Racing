extends PathFollow3D
class_name TrackFollow


var car_id: int = 0
var lap: int = 1
var checkpoint_reached: bool = false

var _car_controller: CarController

@onready var _track: Path3D = get_parent()
@onready var _track_curve: Curve3D = _track.curve


# Add after instatiate (instatiate().with_data(.., ..))
func with_data(id: int, car: CarController) -> PathFollow3D:
	car_id = id
	_car_controller = car
	return self


func _process(_delta: float) -> void:
	progress = _get_track_progress()


func _get_track_progress() -> float:
	var local_pos: Vector3 = _car_controller.global_position * _track.global_transform
	var offset: float = _track_curve.get_closest_offset(local_pos)
	return offset
