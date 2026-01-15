extends PathFollow3D
class_name TrackFollow
## This class is responsible for keeping track of how far a car has progressed along the track


signal lap_changed(lap: int)
signal finished_all_laps(id: int)


var all_laps_finished: bool = false
var total_laps: int = 3
var current_lap: int = 1

var _checkpoint_reached: bool = false
var _car_id: int = 0
var _car_controller: CarController

@onready var _track: Path3D = get_parent()
@onready var _track_curve: Curve3D = _track.curve


# Add after instatiate (instatiate().with_data(.., ..))
func with_data(id: int, car: CarController, laps: int) -> PathFollow3D:
	_car_id = id
	_car_controller = car
	total_laps = laps
	return self


func _process(_delta: float) -> void:
	progress = _get_track_progress()


func _get_track_progress() -> float:
	var local_pos: Vector3 = _car_controller.global_position * _track.global_transform
	var offset: float = _track_curve.get_closest_offset(local_pos)
	return offset


#region Laps

func entered_checkpoint() -> void:
	# Don't track laps after all laps have finished
	if all_laps_finished:
		return
	
	_checkpoint_reached = true


func entered_finish_line() -> void:
	# Check if the car has reached the levels checkpoint. So that the player can't just drive in
	# and out of the finish line to win
	if not _checkpoint_reached or all_laps_finished:
		return
	
	_checkpoint_reached = false
	current_lap += 1
	# Check if it has completed all the laps
	if current_lap > total_laps:
		all_laps_finished = true
		finished_all_laps.emit(_car_id)
	else:
		lap_changed.emit(current_lap)

#endregion
