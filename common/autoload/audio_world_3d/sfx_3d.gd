extends Resource
class_name Sfx3D


enum Type {
	ENGINE,
	TRICK,
	DRIFT,
	DRIFT_CHARGE,
	DRIFT_BOOST,
	CAR_COLLISION,
	HIT_ITEM_BOX,
	USE_ITEM,
	EXPLOSION,
	MISSILE,
}


@export var limit: int = 5
@export var type: Type = Type.ENGINE
@export var volume: float = 0.0
@export var stream: AudioStream

var audio_count: int = 0
var audio_pool: Array[AudioStreamPlayer3D] = []


func has_space() -> bool:
	return audio_count < limit
