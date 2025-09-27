extends SubViewportContainer
class_name PlayerInputController


@export var _cam_follow_speed: float = 5.0
@export var _orientation: Node3D
@export var _player_id_label: Label3D

var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _car_controller: CarController


# Add after instatiate (instatiate().with_data()) to setup controller data
func with_data(id: int, controller: CarController) -> PlayerInputController:
	_player_id = id
	_car_controller = controller
	return self


func _ready() -> void:
	_orientation.global_position = _car_controller.global_position
	_player_id_label.text = "P%s" % (_player_id + 1)


func _input(_event: InputEvent) -> void:
	_throttle_input = Input.get_axis(
			"reverse%s" % _player_id,
			"accelerate%s" % _player_id
	)
	_turn_input = Input.get_axis(
			"turn_r%s" % _player_id,
			"turn_l%s" % _player_id
	)
	
	_car_controller.throttle = _throttle_input
	_car_controller.turn_dir = _turn_input


func _physics_process(delta: float) -> void:
	# Make the camera follow the car controller
	var target_pos: Vector3 = _car_controller.global_position
	_orientation.global_position = _orientation.global_position.lerp(target_pos, _cam_follow_speed * delta)
	_orientation.look_at(_car_controller.global_position + -_car_controller.global_basis.z)
	
	_player_id_label.global_position = target_pos + Vector3(0.0, 1.0, 0.0)
