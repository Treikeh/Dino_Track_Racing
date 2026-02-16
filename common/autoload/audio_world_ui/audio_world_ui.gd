extends Node


@export var _sound_effects: Array[SfxUI] = []

var _sound_effects_dict: Dictionary[SfxUI.Type, SfxUI]


func _ready() -> void:
	for sound_effect: SfxUI in _sound_effects:
		_sound_effects_dict[sound_effect.type] = sound_effect


func play_sound(type: SfxUI.Type, target_position: Vector3) -> void:
	if _sound_effects_dict.has(type):
		var sound_effect: SfxUI = _sound_effects_dict[type]
		# Create audio source
		if sound_effect.has_space():
			sound_effect._audio_count += 1
			
			var player := AudioStreamPlayer.new()
			add_child(player)
			
			player.stream = sound_effect.stream
			player.position = target_position
			player.play()
