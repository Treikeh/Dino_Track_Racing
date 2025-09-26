extends SubViewportContainer
class_name PlayerInputController


@export var _camera_3d: Camera3D
@export var _player_id_label: Label

var _player_id: int = 0
var _car_controller: CarController
var _move_dir: Vector2


# Add after instatiate (instatiate().with_data()) to setup controller data
func with_data(id: int, controller: CarController) -> PlayerInputController:
	_player_id = id
	_car_controller = controller
	return self


func _ready() -> void:
	var camera_transform := RemoteTransform3D.new()
	_car_controller.add_child(camera_transform)
	camera_transform.remote_path = _camera_3d.get_path()
	_player_id_label.text = str(_player_id + 1)


func _input(_event: InputEvent) -> void:
	_move_dir = Input.get_vector(
			"move_r" + str(_player_id),
			"move_l" + str(_player_id),
			"move_b" + str(_player_id),
			"move_f" + str(_player_id)
	)
	
	_car_controller.throttle = _move_dir.y
	_car_controller.turn_dir = _move_dir.x
