extends Control
class_name PlayerJoinEntry


signal player_readied_up
signal player_unreadiedy_up


const TWEEN_DURATION: float = 0.25

@export var _mesh_rotation_speed: float = 30.0
@export var _mesh: Node3D
@export var _player_id_label: Label
@export var _arrow_container: Control
@export var _ready_label: Label
@export var _scream_stream_player: AudioStreamPlayer

var is_ready: bool = false
var current_hat: int = 0

var _player_id: int
var _ready_label_tween: Tween


func with_data(id: int) -> PlayerJoinEntry:
	_player_id = id
	_player_id_label.text = "Player %s" % (id + 1)
	return self


func _ready() -> void:
	# Create input actions for this player
	Globals.setup_player_inputs(_player_id)
	
	AudioWorld3d.play_sound(Sfx3D.Type.ENGINE, _mesh.global_position, 1, 1.25)
	
	_ready_label.hide()


func _process(delta: float) -> void:
	_mesh.rotate_object_local(Vector3.UP, deg_to_rad(_mesh_rotation_speed) * delta)



func _input(event: InputEvent) -> void:
	# Check if right player is pressing the button
	if event.device != _player_id:
		return
	
	if is_ready:
		# Unready
		if event.is_action_pressed("reverse"):
			_unready_up()
		
		# Scream when pressing the drift button
		if event.is_action_pressed("use_held_item%s" % _player_id):
			_start_scream()
			_mesh.is_screaming = true
		elif event.is_action_released("use_held_item%s" % _player_id):
			_scream_stream_player.stream_paused = true
			_mesh.is_screaming = false
	else:
		# Ready up
		if event.is_action_pressed("ui_accept"):
			_ready_up()
		
		# Next hat
		if event.is_action_pressed("ui_right"):
			_show_next_hat()
		# Prev hat
		if event.is_action_pressed("ui_left"):
			_show_prev_hat()


func _ready_up() -> void:
	is_ready = true
	_arrow_container.hide()
	player_readied_up.emit()
	
	_ready_label.show()
	_ready_label.pivot_offset = _ready_label.size / 2.0
	_ready_label.modulate = Color.TRANSPARENT
	_ready_label.scale = Vector2.ONE * 3.0
	_ready_label.rotation_degrees = -15.0 if randi() & 1 else 15.0
	
	if _ready_label_tween:
		_ready_label_tween.kill()
	
	_ready_label_tween = create_tween()
	_ready_label_tween.set_trans(Tween.TRANS_BACK)
	_ready_label_tween.tween_property(_ready_label, "scale", Vector2.ONE, TWEEN_DURATION)
	_ready_label_tween.parallel().tween_property(_ready_label, "modulate", Color.WHITE, TWEEN_DURATION)
	_ready_label_tween.parallel().tween_property(_ready_label, "rotation_degrees", 0.0, TWEEN_DURATION)


func _unready_up() -> void:
	is_ready = false
	_arrow_container.show()
	player_unreadiedy_up.emit()
	
	if _ready_label_tween:
		_ready_label_tween.kill()
	
	_ready_label_tween = create_tween()
	_ready_label_tween.set_trans(Tween.TRANS_BACK)
	_ready_label_tween.tween_property(_ready_label, "scale", Vector2.ZERO, TWEEN_DURATION)
	_ready_label_tween.tween_callback(_ready_label.hide)


func _start_scream() -> void:
	# Start the scream stream if it hasn't started yet
	if !_scream_stream_player.playing and !_scream_stream_player.stream_paused:
		_scream_stream_player.play()
	else: # Unpause scream stream when if it has started
		_scream_stream_player.stream_paused = false


func _show_next_hat() -> void:
	var desired_hat: int = current_hat + 1
	if desired_hat > (_mesh.skeleton.get_child_count() - 2):
		desired_hat = 0
	
	current_hat = desired_hat
	_mesh.enable_hat(current_hat)


func _show_prev_hat() -> void:
	var desired_hat: int = current_hat - 1
	if desired_hat < 0:
		desired_hat = (_mesh.skeleton.get_child_count() - 2)
	
	current_hat = desired_hat
	_mesh.enable_hat(current_hat)
