extends Node3D


const TRACK_FOLLOW: PackedScene = preload("uid://jp5mah0qlvwj")

@export var _track: Path3D

var _car_positions: Array[int]
var _track_follows: Array[TrackFollow]


func add_car(id: int, car: CarController) -> void:
	_car_positions.append(id)
	
	# Spawn the car and set it's position
	@warning_ignore("integer_division")
	# The row the current car will spawn on
	var spawn_row: int = id / 4
	car.global_position.y = 5.0
	# Spawn the cars in a row starting form the left and going right. If there's more than 4
	# cars on a row move the 5th car back and to the left and start a new row. This continues
	# until all cars have been spawned
	car.global_position.x = -3.0 + (2.0 * (id - (spawn_row * 4)))
	car.global_position.z = 3.0 * spawn_row
	
	# Add a track follow to the car to track how far along the track it is
	var track_follow: TrackFollow = TRACK_FOLLOW.instantiate().with_data(id, car)
	_track.add_child(track_follow)
	_track_follows.append(track_follow)


func _process(_delta: float) -> void:
	# Sort the _car_positions array so that the order is the same as how far each car has gotten
	_car_positions.sort_custom(_sort_positions)
	get_tree().current_scene.car_positions_updated.emit(_car_positions)


func _sort_positions(a: int, b: int) -> bool:
	return _track_follows[a].progress > _track_follows[b].progress
