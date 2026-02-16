extends Resource
class_name Sfx3D


enum Type {
	ENGINE,
	TRICK,
}


@export var limit: int = 5
@export var type: Type = Type.ENGINE
@export var stream: AudioStream

var _audio_count: int = 0


func has_space() -> bool:
	return _audio_count < limit
