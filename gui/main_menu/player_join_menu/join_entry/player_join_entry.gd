extends Control
class_name PlayerJoinEntry


@export var _mesh_rotation_speed: float = 30.0
@export var _player_id_label: Label
@export var _mesh: Node3D
@export var _scream_stream_player: AudioStreamPlayer

var _player_id: int
var _throttle_input: float = 1.0
var _turn_input: float = 0.0


func with_data(id: int) -> PlayerJoinEntry:
	_player_id = id
	_player_id_label.text = "Player %s" % (id + 1)
	return self


func _ready() -> void:
	# Create input actions for this player
	Globals.set_up_player_inputs(_player_id)


func _process(delta: float) -> void:
	_mesh.rotate_object_local(Vector3.UP, deg_to_rad(_mesh_rotation_speed + _turn_input) * delta)


func _physics_process(delta: float) -> void:
	# Make the mesh rotate faster when turning with the stick
	_turn_input += Input.get_axis("turn_l%s" % _player_id, "turn_r%s" % _player_id) * 30.0 * delta
	
	# Change the pitch when accelerating or reversing
	_throttle_input += Input.get_axis("reverse%s" % _player_id, "accelerate%s" % _player_id) * delta
	# Clamp value so that it doesn't become too high/low
	_throttle_input = clampf(_throttle_input, 0.1, 5.0)
	_scream_stream_player.pitch_scale = _throttle_input


func _input(event: InputEvent) -> void:
	# Make a sound when drifting
	if event.is_action_pressed("drift%s" % _player_id):
		_start_scream()
	elif event.is_action_released("drift%s" % _player_id):
		_scream_stream_player.stream_paused = true


func _start_scream() -> void:
	# Start the scream stream if it hasn't started yet
	if !_scream_stream_player.playing and !_scream_stream_player.stream_paused:
		_scream_stream_player.play()
	else: # Unpause scream stream when if it has started
		_scream_stream_player.stream_paused = false
