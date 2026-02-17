extends Node


@export var _sound_effects: Array[SfxUI] = []

var _sound_effects_dict: Dictionary[SfxUI.Type, SfxUI]


func _ready() -> void:
	for sound_effect: SfxUI in _sound_effects:
		_sound_effects_dict[sound_effect.type] = sound_effect


func play_sound(type: SfxUI.Type) -> void:
	if _sound_effects_dict.has(type):
		var sound_effect: SfxUI = _sound_effects_dict[type]
		# Create audio source
		if sound_effect.has_space():
			sound_effect.audio_count += 1
			
			var player := AudioStreamPlayer.new()
			add_child(player)
			player.finished.connect(_destroy_sfx.bind(sound_effect, player))
			
			player.bus = "Effects"
			player.stream = sound_effect.stream
			player.volume_db = sound_effect.volume
			player.play()


func _destroy_sfx(sound_effect: SfxUI, player: AudioStreamPlayer) -> void:
	sound_effect.audio_count -= 1
	player.queue_free()
