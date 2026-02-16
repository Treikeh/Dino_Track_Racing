extends AudioListener3D


@export var _sound_effects: Array[Sfx3D] = []

var _virtual_audio_listeners: Array[Node] = []
var _sound_effects_dict: Dictionary[Sfx3D.Type, Sfx3D]


func _ready() -> void:
	for sound_effect: Sfx3D in _sound_effects:
		_sound_effects_dict[sound_effect.type] = sound_effect


func  update_audio_listeners() -> void:
	_virtual_audio_listeners = get_tree().get_nodes_in_group("va_listener")


func play_sound_at_point(sound: Sfx3D.Type, pos: Vector3) -> void:
	if _sound_effects_dict.has(sound):
		var sound_effect: Sfx3D = _sound_effects_dict[sound]
		# Create audio source
		if sound_effect.has_space():
			# Get the closest audio listener
			var listener: Node3D = _get_closest_listener(pos)
			var listener_pos: Vector3 = listener.global_position
			var listener_distance: float = listener_pos.distance_squared_to(pos)
			
			# Check if the sound is too far away form the listener
			if listener_distance > 500.0:
				print("Sound too far away")
				return
			
			sound_effect._audio_count += 1
			
			# Create new audio player
			#TODO: Cache or pool the players
			var player := AudioStreamPlayer3D.new()
			add_child(player)
			
			var local_pos: Vector3 = pos - listener_pos
			player.stream = sound_effect.stream
			player.position = local_pos
			player.play()
			
			player.finished.connect(_on_sfx_finished.bind(sound, player))

# Get the position of te virtual listener that is closest to target pos
func _get_closest_listener(target_pos: Vector3) -> Node3D:
	var distance: float = INF
	var listener: Node3D = self
	for l: Node3D in _virtual_audio_listeners:
		var pos: Vector3 = l.global_position
		var d: float = target_pos.distance_squared_to(pos)
		if d < distance:
			distance = d
			listener = l
	
	return listener


func _on_sfx_finished(sound: Sfx3D.Type, player: AudioStreamPlayer3D) -> void:
	_sound_effects_dict[sound]._audio_count -= 1
	player.queue_free()
