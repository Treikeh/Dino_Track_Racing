extends Node3D
class_name Level3D


signal countdown_updated(seconds_left: int)
signal car_positions_updated(car_positions: Array[int])


const LEVEL_UI_SCENE: PackedScene = preload("res://gui/level_ui/level_ui.tscn")
const CAR_CONTROLLER: PackedScene = preload("uid://c56dtjon3irj1")
const PLAYER_INPUT_CONTROLLER: PackedScene = preload("uid://d1f50k3xa7iar")
const TRACK_FOLLOW: PackedScene = preload("uid://jp5mah0qlvwj")

@export var _lap_count: int = 3
## How many seconds the countdown should be before starting the race.
## Needs to be 1 more than intended because the number is only updated after 1 sec has passed. This 
## is to make sure the loading screen has finished fading out before the countdown starts.
@export var _countdown_duration: int = 4
@export var _track: Path3D
@export var _spawn_point: Node3D

var _race_active: bool = false
# How long the race has lasted
var _race_duration: float = 0.0
var _level_ui: CanvasLayer
# Race positions of each car (1st, 2nd, 3rd, etc..). Array index = position(0 = 1st), int = car id
var _car_positions: Array[int]
# All the cars added to the leve and the asociated id to that car. int = car id
var _cars: Dictionary[int, CarController]
# int = car id
var _track_follows: Dictionary[int, TrackFollow]


func _ready() -> void:
	# Add the level ui to the scene
	_level_ui = LEVEL_UI_SCENE.instantiate()
	add_child(_level_ui)
	
	_spawn_players()
	_start_countdown()


func _process(delta: float) -> void:
	# Sort the _car_positions array so that the first position in the array is the player that has
	# gotten the furthest
	_car_positions.sort_custom(_sort_positions)
	car_positions_updated.emit(_car_positions)
	
	if _race_active:
		_race_duration += delta


#region Spawning

func _spawn_players() -> void:
	var player_count: int = Globals.players.size()
	# Get how many columns the _viewports_container should have based on the player_count
	var viewport_columns: int = ceili(sqrt(player_count))
	Globals.viewports_container.columns = viewport_columns
	
	
	# Spawn players
	for p: int in player_count:
		var player_id: int = Globals.players.keys()[p]
		# Add car to world
		var car: CarController = _add_car(player_id)
		var track_follow: TrackFollow =_add_track_follow(player_id, car)
		_add_player_input(player_id, car, track_follow)
		
		# Set the spawn position of the car
		car.global_position = _get_spawn_position(p)
		print("Player id: %s" % p)
	
	await get_tree().process_frame
	
	if Globals.allow_cpus:
		var cpu_count: int = Globals.min_cars_ammount - player_count
		for c: int in cpu_count:
			var cpu_id: int = player_count + c
			var car: CarController = _add_car(cpu_id)
			var track_follow: TrackFollow = _add_track_follow(cpu_id, car)
			_add_cpu_controller(car, track_follow)
			
			# Set spawn position of car
			car.global_position = _get_spawn_position(cpu_id)
	
	
	# Fill the empty spaces with stuff. Could maybe add a cinematic camera that looks at different players
	# Get how many rows the _viewports_container will have
	var viewport_rows: int = ceili(float(player_count) / viewport_columns)
	# Get how many empty spaces there will be after all players have been added
	var empty_spaces: int = (viewport_columns * viewport_rows) - player_count
	for i: int in empty_spaces:
		# Do something
		pass


func _add_car(id: int) -> CarController:
	# Add car to level
	var car: CarController = CAR_CONTROLLER.instantiate()
	add_child(car)
	# Disable car until the countdown timer reaches 0
	car.set_movement_state(CarController.MovementState.DISABLED)
	# Add cars id to array for sorting positions
	_car_positions.append(id)
	_cars[id] = car
	return car


func _add_track_follow(id: int, car: CarController) -> TrackFollow:
	# Add track follow to level
	var track_follow: TrackFollow = TRACK_FOLLOW.instantiate().with_data(id, car, _lap_count)
	_track.add_child(track_follow)
	
	track_follow.finished_all_laps.connect(_on_car_finished_all_laps)
	
	_track_follows[id] = track_follow
	return track_follow


func _add_player_input(id: int, car: CarController, track_follow: TrackFollow) -> void:
	# Add palyer inputs and connect it to the car
	var player_inputs: PlayerInputController = (
			PLAYER_INPUT_CONTROLLER.instantiate().with_data(id, car, track_follow)
	)
	Globals.viewports_container.add_child(player_inputs)
	
	# Connect signals to update HUD on the player input (The inputs also have the HUD)
	countdown_updated.connect(player_inputs.on_countdown_updated)
	car_positions_updated.connect(player_inputs.on_car_positions_updated)


func _add_cpu_controller(car: CarController, track_follow: TrackFollow) -> void:
	var cpu_controller := EnemyCpuController.new(car, track_follow)
	car.add_child(cpu_controller)


# Get the spawn position of a car based on the order it was added to the level.
# It starts on the left and goes towards the right. A new row starts every 4 cars.
#  1  2  3  4
#  5  6  7  8
#  9 10 11 12
# 13 14 15 16
func _get_spawn_position(spawn_number: int) -> Vector3:
	@warning_ignore("integer_division")
	# The row the current car will spawn on
	var spawn_row: int = spawn_number / 4
	
	var x: float = -3.0 + (2.0 * (spawn_number - (spawn_row * 4)))
	var y: float = 1.0
	var z: float = 3.0 * spawn_row
	return _spawn_point.global_position + Vector3(x, y, z)

#endregion


func _start_countdown() -> void:
	var timer := Timer.new()
	add_child(timer)
	
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_countdown_timer_timeout.bind(timer))
	timer.start()


func _on_countdown_timer_timeout(countdown_timer: Timer) -> void:
	_countdown_duration -= 1
	if _countdown_duration <= 0:
		countdown_timer.stop()
		# Enable all cars
		get_tree().call_group("car", "set_movement_state", CarController.MovementState.NORMAL)
		_race_active = true
	# Update UI to players
	countdown_updated.emit(_countdown_duration)


# Logic for how the positions (1st, 2nd, 3rd, etc..) of the cars should be sorted
func _sort_positions(a: int, b: int) -> bool:
	# Check if both track follows are on the same lap
	if _track_follows[a].current_lap != _track_follows[b].current_lap:
		# Compare the lap both cars are on
		return _track_follows[a].current_lap > _track_follows[b].current_lap
	else:
		# Compare the progress of both cars when they're on the same lap
		return _track_follows[a].progress > _track_follows[b].progress


func _on_car_finished_all_laps(car_id: int) -> void:
	# Set how long it took a player ro finish all the laps
	if Globals.players.has(car_id):
		Globals.players[car_id] = _race_duration
	
	_level_ui.finished_cars[car_id] = _race_duration
	
	
	for i:int in Globals.players:
		var track_follow: TrackFollow = _track_follows[i]
		if not track_follow.all_laps_finished:
			return
	
	# Check if all cars have completed the level
	#for i: int in _track_follows:
	#	# Exit out of the function if one of the players hasn't finished all the laps
	#	if not _track_follows[i].all_laps_finished:
	#		return
	
	_end_level()


func _end_level() -> void:
	_race_active = false
	_level_ui.on_race_ended()


func get_id_from_car(car: CarController) -> int:
	return _cars.find_key(car)


func get_race_pos_from_car(car: CarController) -> int:
	var car_id: int = get_id_from_car(car)
	return _car_positions.find(car_id)


func get_car_from_id(id: int) -> CarController:
	return _track_follows[id]._car_controller


func get_car_from_race_position(race_position: int) -> CarController:
	var car_id: int = _car_positions[race_position]
	return _track_follows[car_id]._car_controller
