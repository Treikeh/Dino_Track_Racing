extends AudioListener3D
#INSPIRATION: Aarimous - https://www.youtube.com/watch?v=Egf2jgET3nQ


@export var _sound_effects: Array[Sfx3D] = []

var _virtual_audio_listeners: Array[Node] = []
var _sound_effects_dict: Dictionary[Sfx3D.Type, Sfx3D] = {}

# Queue for sounds to play
var _sound_queue: Dictionary[Sfx3D.Type, Array] = {}


func _ready() -> void:
	for sound_effect: Sfx3D in _sound_effects:
		_sound_effects_dict[sound_effect.type] = sound_effect


func _process(_delta: float) -> void:
	_update_sound_queue()


func  update_audio_listeners() -> void:
	make_current()
	_virtual_audio_listeners = get_tree().get_nodes_in_group("va_listener")


func stop_all_sounds() -> void:
	_sound_queue.clear()
	# Reset sound effects
	for sound: Sfx3D.Type in _sound_effects_dict:
		var sound_effect: Sfx3D = _sound_effects_dict[sound]
		sound_effect.audio_count = 0
		sound_effect.audio_pool.clear()
	
	# Remove all audio players
	for child: Node in get_children():
		if child is AudioStreamPlayer3D:
			remove_child(child)
			child.queue_free()


## Play a sound that will be "attached" to a target. Every frame the sound will move to the target's
## position, but only if the priority is high enough. Priority is used to check if a sound should be
## continious, and it's priority.
func play_sound(sound: Sfx3D.Type, pos: Vector3, priority: int = 0, pitch: float = 1.0) -> void:
	if _sound_effects_dict.has(sound):
		# Get the closest audio listener
		var listener: Node3D = _get_closest_listener(pos)
		var listener_pos: Vector3 = listener.global_position
		var listener_distance: float = listener_pos.distance_squared_to(pos)
		# Check if the sound is too far away form the listener
		if listener_distance > 750.0:
			#print("Sound too far away")
			return
		
		var local_pos: Vector3 = pos - listener_pos
		var sound_effect: Sfx3D = _sound_effects_dict[sound]
		
		# Check if the priority is larger than 0
		if priority > 0:
			var sound_data := SoundQueueData.new()
			sound_data.local_pos = local_pos
			sound_data.priority = priority
			sound_data.pitch = pitch
			
			# Add the sound data to the queue
			if not _sound_queue.has(sound):
				_sound_queue.set(sound, [])
			_sound_queue[sound].append(sound_data)
		
		# Create new sound effects if the limit hasn't been reached
		if sound_effect.has_space():
			_create_sfx_player(sound_effect, local_pos, pitch)


# Get the audio listener that is closest to the target position
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


func _create_sfx_player(sound_effect: Sfx3D, local_pos: Vector3, pitch: float) -> void:
	# Create new audio stream player
	var player := AudioStreamPlayer3D.new()
	add_child(player)
	player.finished.connect(_destroy_sfx_player.bind(sound_effect, player))
	
	sound_effect.audio_count += 1
	sound_effect.audio_pool.append(player)
	
	# Setup player
	player.bus = "Effects"
	player.stream = sound_effect.stream
	player.position = local_pos
	player.pitch_scale = pitch
	player.volume_db = sound_effect.volume
	player.play()


func _destroy_sfx_player(sound_effect: Sfx3D, player: AudioStreamPlayer3D) -> void:
	sound_effect.audio_pool.erase(player)
	sound_effect.audio_count -= 1
	player.queue_free()


#region Sound Queue

class SoundQueueData:
	var priority: int
	var local_pos: Vector3
	var pitch: float


func _update_sound_queue() -> void:
	# Go through every sound and only play the ones with the highest priority
	for type: Sfx3D.Type in _sound_queue:
		# Filter sounds based on priority
		var sounds: Array = _sound_queue[type]
		sounds.sort_custom(_sort_queue)
		
		var sound_effect: Sfx3D = _sound_effects_dict[type]
		var pool_count: int = sound_effect.audio_pool.size()
		
		#print("Sound queue: %s, Limit: %s" % [sounds.size(), sound_effect.limit])
		for sound: int in pool_count:
			var sound_count: int = sounds.size()
			var player: AudioStreamPlayer3D = sound_effect.audio_pool[sound]
			if sound < sound_count:
				var sound_data: SoundQueueData = sounds[sound]
				player.position = sound_data.local_pos
				player.pitch_scale = sound_data.pitch
				player.volume_db = sound_effect.volume
			else:
				player.volume_linear = 0.0
		
		# Clear the queue at the end of the frame
		_sound_queue[type].clear()


func _sort_queue(a: SoundQueueData, b: SoundQueueData) -> bool:
	return a.priority > b.priority

#endregion
