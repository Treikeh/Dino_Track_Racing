extends Control
class_name PlayerInputController
## This class in responsible for allowing a player to control a car

@export_group("Car")
@export var _cam_follow_speed: float = 6.0
@export var _orientation: Node3D
@export var _id_label: Label3D

@export_group("HUD")
@export var _position_label: Label
@export var _speedometer: Label
@export var _lap_label: Label
@export var _countdown_label: Label
@export var _item_image: TextureRect

var _finished_all_laps: bool = false
var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _car_controller: CarController
var _track_follow: TrackFollow


# Add after instatiate (instatiate().with_data(.., ..)) to setup controller data
func with_data(
		id: int,
		car_controller: CarController,
		track_follow: TrackFollow
) -> PlayerInputController:
	_player_id = id
	_car_controller = car_controller
	_track_follow = track_follow
	return self


func _ready() -> void:
	# Create new input actions (if they don't exist)
	Globals.set_up_player_inputs(_player_id)
	
	# Connect to car signals
	#NOTE: Could also be in the with_data() function, but it looks nicer here
	_car_controller.item_picked_up.connect(_on_car_item_picked_up)
	
	# Connect to trak follow signals
	#NOTE: This could also be in the with_data() function
	_track_follow.lap_changed.connect(_on_lap_changed)
	_track_follow.finished_all_laps.connect(_on_finished_all_laps)
	
	_id_label.text = "P%s" % (_player_id + 1)
	_lap_label.text = "1/%s" % _track_follow.total_laps
	_orientation.global_position = _car_controller.global_position


func _input(event: InputEvent) -> void:
	# Disable player input when the player has finished the last lap
	if _finished_all_laps:
		return
	
	_throttle_input = Input.get_axis(
			"reverse%s" % _player_id,
			"accelerate%s" % _player_id
	)
	_turn_input = Input.get_axis(
			"turn_r%s" % _player_id,
			"turn_l%s" % _player_id
	)
	
	# Drift input
	if event.is_action_pressed("drift%s" % _player_id):
		_car_controller.try_dirft()
	elif event.is_action_released("drift%s" % _player_id):
		_car_controller.release_drift()
	
	# Use item input
	if event.is_action_pressed("use_held_item%s" % _player_id):
		_car_controller.use_held_item()
	
	_car_controller.throttle = _throttle_input
	_car_controller.turn_input = _turn_input


func _physics_process(delta: float) -> void:
	# Make the camera follow the car controller
	var target_pos: Vector3 = _car_controller.global_position
	_id_label.global_position = target_pos + Vector3(0.0, 1.0, 0.0)
	_id_label.look_at(_get_look_at_pos())
	
	var target_quat: Quaternion = _id_label.quaternion
	_orientation.global_position = _orientation.global_position.lerp(target_pos, _cam_follow_speed * delta)
	_orientation.quaternion = _orientation.quaternion.slerp(target_quat, 4.0 * delta)
	
	_speedometer.text = "%s kmh" % int(snappedf(_car_controller.speed_khm, 1.0))
	
	# Make the car automatically move when the player has finished the last lap
	#TODO: Replace with a simple AI that follow the track
	if _finished_all_laps:
		_car_controller.throttle = 1.0
		_car_controller.turn_input = 1.0
		_car_controller.stop_drift()


func _get_look_at_pos() -> Vector3:
	var car_pos: Vector3 = _car_controller.global_position
	var car_vel: Vector3 = _car_controller.linear_velocity
	var car_dir: Vector3 = -_car_controller.global_basis.z
	return car_pos + (car_dir * (3.0 + (4.0 * _throttle_input))) + car_vel


#region UI signal functions

func on_countdown_updated(seconds_left: int) -> void:
	_countdown_label.show()
	if seconds_left <= 0:
		_update_countdown_label("GO!", 2.0)
	else:
		_update_countdown_label(str(seconds_left))


func on_car_positions_updated(car_positions: Array[int]) -> void:
	_position_label.text = str(car_positions.find(_player_id) + 1)


func _on_lap_changed(lap: int) -> void:
	_lap_label.text = "%s/%s" % [lap, _track_follow.total_laps]


func _on_finished_all_laps(_car_id: int) -> void:
	_finished_all_laps = true
	_update_countdown_label("FINISHED", 2.0)


func _on_car_item_picked_up(item: ItemResource) -> void:
	_item_image.texture = item.icon

#endregion


func _update_countdown_label(
		new_text: String,
		visible_duration: float = 0.6,
		fade_duration: float = 0.2,
) -> void:
	# Reset countdown label
	_countdown_label.text = new_text
	_countdown_label.show()
	_countdown_label.modulate = Color.TRANSPARENT
	
	var tween: Tween = create_tween()
	tween.tween_property(_countdown_label, "modulate", Color.WHITE, fade_duration)
	tween.tween_interval(visible_duration)
	tween.tween_property(_countdown_label, "modulate", Color.TRANSPARENT, fade_duration)
	tween.tween_callback(_countdown_label.hide)
