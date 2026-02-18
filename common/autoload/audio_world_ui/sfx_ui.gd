extends Resource
class_name SfxUI


enum Type {
	SELECT,
	PRESS,
	ITEM_RECIVED,
	SWOOSH,
}


@export var limit: int = 5
@export var type: Type = Type.SELECT
@export var volume: float = 0.0
@export var stream: AudioStream

var audio_count: int = 0


func has_space() -> bool:
	return audio_count < limit
