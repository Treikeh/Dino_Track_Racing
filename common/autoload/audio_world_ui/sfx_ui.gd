extends Resource
class_name SfxUI


enum Type {
	SELECT,
}


@export var limit: int = 4
@export var type: Type = Type.SELECT
@export var stream: AudioStream

var _audio_count: int = 0


func has_space() -> bool:
	return _audio_count < limit
