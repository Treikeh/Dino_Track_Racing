extends Node3D
class_name Level3D


const CAR_CONTROLLER: PackedScene = preload("uid://c56dtjon3irj1")
const PLAYER_INPUT_CONTROLLER: PackedScene = preload("uid://d1f50k3xa7iar")
const TRACK_FOLLOW: PackedScene = preload("uid://jp5mah0qlvwj")

@export var _countdown_duration: int = 3
@export var _track: Path3D
@export var _spawn_point: Node3D

# Race positions of each car (1st, 2nd, 3rd, etc..)
var _car_positions: Array[int]
# int = car id
var _track_follows: Dictionary[int, TrackFollow]


func _ready() -> void:
	_spawn_players()
	_start_countdown()


func _process(_delta: float) -> void:
	# Sort the _car_positions array so that the first position in the array is the player that has
	# gotten the furthest
	_car_positions.sort_custom(_sort_positions)
	Globals.car_positions_updated.emit(_car_positions)


#region Spawning

func _spawn_players() -> void:
	var player_count: int = Globals.player_count.size()
	# Get how many columns the _viewports_container should have based on the player_count
	var viewport_columns: int = ceili(sqrt(player_count))
	Globals.viewports_container.columns = viewport_columns
	
	
	# Spawn players
	for i: int in Globals.player_count.size():
		var id: int = Globals.player_count[i]
		# Add car to world
		var car: CarController = _add_car(id)
		_add_track_follow(id, car)
		_add_player_input(id, car)
		
		# Set the spawn position of the car
		car.global_position = _get_spawn_position(i)
	
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
	car.set_car_enabled(false)
	# Add cars id to array for sorting positions
	_car_positions.append(id)
	return car


func _add_track_follow(id: int, car: CarController) -> void:
	var track_follow: TrackFollow = (
			TRACK_FOLLOW.instantiate().with_data(id, car)
	)
	_track.add_child(track_follow)
	_track_follows[id] = track_follow


func _add_player_input(id: int, car: CarController) -> void:
	# Add palyer inputs and connect it to the car
	var player_inputs: PlayerInputController = (
			PLAYER_INPUT_CONTROLLER.instantiate().with_data(id, car)
	)
	Globals.viewports_container.add_child(player_inputs)


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
	var y: float = 5.0
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
		get_tree().call_group("car", "set_car_enabled", true)
	# Update UI to players
	Globals.countdown_updated.emit(_countdown_duration)


# Logic for how the positions (1st, 2nd, 3rd, etc..) of the cars should be sorted
func _sort_positions(a: int, b: int) -> bool:
	# Check if both track follows are on the same lap
	if _track_follows[a].lap != _track_follows[b].lap:
		# Compare the lap both cars are on
		return _track_follows[a].lap > _track_follows[b].lap
	else:
		# Compare the progress of both cars when they're on the same lap
		return _track_follows[a].progress > _track_follows[b].progress


func _on_finish_line_area_entered(area: Area3D) -> void:
	var track_follow: TrackFollow = area.get_parent()
	if track_follow.checkpoint_reached:
		track_follow.lap += 1
		if track_follow.lap >= 4:
			print("GAME OVER")
		else:
			print("New lap: %s" % track_follow.lap)
			Globals.lap_changed.emit(track_follow.car_id, track_follow.lap)


func _on_checkpoint_area_entered(area: Area3D) -> void:
	var track_follow: TrackFollow = area.get_parent()
	track_follow.checkpoint_reached = true
	print("Checkpoint reached for lap %s" % track_follow.lap)
