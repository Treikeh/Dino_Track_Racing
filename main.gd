extends Node


const CAR_CONTROLLER: PackedScene = preload("uid://c56dtjon3irj1")
const PLAYER_INPUT_CONTROLLER: PackedScene = preload("uid://d1f50k3xa7iar")

@export var _player_count: int = 2
@export var _ui: CanvasLayer
@export var _viewports_container: GridContainer

var _input_actions: Array[String] = [
	"move_f",
	"move_b",
	"move_l",
	"move_r",
]


func _on_player_button_pressed(player_count: int) -> void:
	_ui.hide()
	_player_count = player_count
	# Set the columns on the viewport containter based on how many players are playing
	match _player_count:
		1:
			_viewports_container.columns = 1
		_:
			_viewports_container.columns = 2
	
	for player_id: int in _player_count:
		# Add car to world
		var car: CarController = CAR_CONTROLLER.instantiate()
		add_child(car)
		car.global_position.y = 5.0
		car.global_position.x = 5.0 * player_id
		
		_add_player(player_id, car)


func _add_player(player_id: int, car: CarController) -> void:
	var player_inputs: PlayerInputController = PLAYER_INPUT_CONTROLLER.instantiate().with_data(player_id, car)
	_viewports_container.add_child(player_inputs)
	
	_set_up_player_inputs(player_id)


## Add inputs the palyer with the matching id can use
func _set_up_player_inputs(player_id: int) -> void:
	for action: String in _input_actions:
		# Get event related to the input action
		var action_events: Array = InputMap.action_get_events(action)
		
		# Crate new input actions related to each player
		var new_action: String = action + str(player_id)
		InputMap.add_action(new_action)
		# Duplicate the old events and add them to the input action
		for event: InputEvent in action_events:
			var new_event: InputEvent = event.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			new_event.device = player_id
			InputMap.action_add_event(new_action, new_event)
