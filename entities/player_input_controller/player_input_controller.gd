extends Control
class_name PlayerInputController


@export var _cam_follow_speed: float = 6.0
@export var _orientation: Node3D
@export var _id_label: Label3D

@export_group("HUD")
@export var _position_label: Label
@export var _speedometer: Label

var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _car_controller: CarController

# Input actions to copy and assign to each new player
var _input_actions: Array[String] = [
	"accelerate",
	"reverse",
	"turn_l",
	"turn_r",
	"reset",
]


# Add after instatiate (instatiate().with_data(.., ..)) to setup controller data
func with_data(id: int, controller: CarController) -> PlayerInputController:
	_player_id = id
	_car_controller = controller
	return self


func _ready() -> void:
	_set_up_player_inputs()
	_orientation.global_position = _car_controller.global_position
	_id_label.text = "P%s" % (_player_id + 1)
	get_tree().current_scene.car_positions_updated.connect(_on_car_positions_updated)


func _input(event: InputEvent) -> void:
	_throttle_input = Input.get_axis(
			"reverse%s" % _player_id,
			"accelerate%s" % _player_id
	)
	_turn_input = Input.get_axis(
			"turn_r%s" % _player_id,
			"turn_l%s" % _player_id
	)
	
	# Don't allow player to drive when flipped over
	if _car_controller.global_basis.y.dot(Vector3.UP) < 0.25:
		_throttle_input = 0.0
		# Reset the car when it has flipped over and the player pressed the reset button
		if event.is_action_pressed("reset%s" % _player_id):
			_car_controller.reset()
	
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
	
	_speedometer.text = "%s kmh" % snappedf(_car_controller.speed_khm, 1.0)


## Crate new input actions for each player
func _set_up_player_inputs() -> void:
	for action: String in _input_actions:
		var new_action: String = action + str(_player_id)
		# Don't add the new action if it allready exists
		if InputMap.has_action(new_action):
			return
		
		# Get event related to the input action
		var action_events: Array = InputMap.action_get_events(action)
		
		InputMap.add_action(new_action)
		# Duplicate the old events and add them to the input action
		for event: InputEvent in action_events:
			var new_event: InputEvent = event.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			new_event.device = _player_id
			InputMap.action_add_event(new_action, new_event)


func _get_look_at_pos() -> Vector3:
	var car_pos: Vector3 = _car_controller.global_position
	var car_vel: Vector3 = _car_controller.linear_velocity
	var car_dir: Vector3 = -_car_controller.global_basis.z
	return car_pos + (car_dir * (3.0 + (4.0 * _throttle_input))) + car_vel


func _on_car_positions_updated(car_positions: Array[int]) -> void:
	_position_label.text = str(car_positions.find(_player_id) + 1)
