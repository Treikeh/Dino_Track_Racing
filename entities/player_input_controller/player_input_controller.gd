extends Control
class_name PlayerInputController

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
var _lap_count: int = 3
var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _drift_input: bool
var _car_controller: CarController


# Add after instatiate (instatiate().with_data(.., ..)) to setup controller data
func with_data(id: int, controller: CarController, lap_count: int = 3) -> PlayerInputController:
	_player_id = id
	_car_controller = controller
	_lap_count = lap_count
	return self


func _ready() -> void:
	Globals.countdown_updated.connect(_on_countdown_updated)
	Globals.car_positions_updated.connect(_on_car_positions_updated)
	Globals.lap_changed.connect(_on_lap_changed)
	Globals.finished_all_laps.connect(_on_finished_all_laps)
	
	# Create new input actions (if they don't exist)
	Globals.set_up_player_inputs(_player_id)
	
	# Connect to car signals
	#NOTE: Could also be in the with_data() function, but it looks nicer here
	_car_controller.picked_up_item.connect(_on_car_picked_up_item)
	
	_id_label.text = "P%s" % (_player_id + 1)
	_lap_label.text = "1/%s" % _lap_count
	_orientation.global_position = _car_controller.global_position


func _input(_event: InputEvent) -> void:
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
	
	_drift_input = Input.is_action_pressed("drift%s" % _player_id)
	
	if _event.is_action_pressed("use_held_item%s" % _player_id):
		_car_controller.use_held_item()
	
	_car_controller.throttle = _throttle_input
	_car_controller.turn_input = _turn_input
	_car_controller.drift_input = _drift_input


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
		_car_controller.drift_input = 0.0


func _get_look_at_pos() -> Vector3:
	var car_pos: Vector3 = _car_controller.global_position
	var car_vel: Vector3 = _car_controller.linear_velocity
	var car_dir: Vector3 = -_car_controller.global_basis.z
	return car_pos + (car_dir * (3.0 + (4.0 * _throttle_input))) + car_vel


#region UI signal functions

func _on_countdown_updated(seconds_left: int) -> void:
	_countdown_label.show()
	if seconds_left <= 0:
		_countdown_label.text = "GO!"
		await get_tree().create_timer(2.0).timeout
		_countdown_label.hide()
	else:
		_countdown_label.text = str(seconds_left)


func _on_car_positions_updated(car_positions: Array[int]) -> void:
	_position_label.text = str(car_positions.find(_player_id) + 1)


func _on_lap_changed(car_id: int, lap: int) -> void:
	if _player_id == car_id:
		_lap_label.text = "%s/%s" % [lap, _lap_count]


func _on_finished_all_laps(car_id: int) -> void:
	if _player_id == car_id and not _finished_all_laps:
		_finished_all_laps = true
		_countdown_label.show()
		_countdown_label.text = "FINISHED!"
		await get_tree().create_timer(2.0).timeout
		_countdown_label.hide()


func _on_car_picked_up_item(item: ItemResource) -> void:
	_item_image.texture = item.icon

#endregion
