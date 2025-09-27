extends Node


const CAR_CONTROLLER: PackedScene = preload("uid://c56dtjon3irj1")
const PLAYER_INPUT_CONTROLLER: PackedScene = preload("uid://d1f50k3xa7iar")

@export var _ui: CanvasLayer
@export var _viewports_container: GridContainer

var _input_actions: Array[String] = [
	"accelerate",
	"reverse",
	"turn_l",
	"turn_r",
]


func _ready() -> void:
	_ui.player_button_pressed.connect(_on_player_button_pressed)
	_ui.return_to_main_menu.connect(_reset_game)


func _on_player_button_pressed(player_count: int) -> void:
	# Set the columns on the viewport containter based on how many players are playing
	match player_count:
		1:
			_viewports_container.columns = 1
		_:
			_viewports_container.columns = 2
	
	# Spawn players
	for player_id: int in player_count:
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
		# Don't add new actions if they allredy exist
		if InputMap.has_action(new_action):
			return
		
		InputMap.add_action(new_action)
		# Duplicate the old events and add them to the input action
		for event: InputEvent in action_events:
			var new_event: InputEvent = event.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			new_event.device = player_id
			InputMap.action_add_event(new_action, new_event)


func _reset_game() -> void:
	# Remove palyers and cars
	for child: Node in _viewports_container.get_children():
		_viewports_container.remove_child(child)
		child.queue_free()
	
	for car in get_tree().get_nodes_in_group("car"):
		car.queue_free()
