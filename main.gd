extends Node


const CAR_CONTROLLER: PackedScene = preload("uid://c56dtjon3irj1")
const PLAYER_INPUT_CONTROLLER: PackedScene = preload("uid://d1f50k3xa7iar")

@export var _world_3d: Node3D
@export var _ui: CanvasLayer
@export var _viewports_container: GridContainer


func _ready() -> void:
	_ui.play_button_pressed.connect(_on_play_button_pressed)
	
	#_on_player_button_pressed(1)
	#_ui.hide()


func _on_play_button_pressed(player_count: int) -> void:
	# Get how many columns the _viewports_container should have based on the player_count
	var viewport_columns: int = ceili(sqrt(player_count))

	_viewports_container.columns = viewport_columns
	
	# Spawn players
	for player_id: int in player_count:
		# Add car to world
		var car: CarController = CAR_CONTROLLER.instantiate()
		_world_3d.add_child(car)
		_world_3d.add_car(player_id, car)
		
		# Add palyer inputs and connect it to the car
		var player_inputs: PlayerInputController = (
				PLAYER_INPUT_CONTROLLER.instantiate().with_data(player_id, car)
		)
		_viewports_container.add_child(player_inputs)
	
	# Fill the empty spaces with stuff. Could maybe add a cinematic camera that looks at different players
	# Get how many rows the _viewports_container will have
	var viewport_rows: int = ceili(float(player_count) / viewport_columns)
	# Get how many empty spaces there will be after all players have been added
	var empty_spaces: int = (viewport_columns * viewport_rows) - player_count
	for i: int in empty_spaces:
		# Do something
		pass
