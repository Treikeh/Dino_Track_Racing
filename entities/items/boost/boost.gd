extends Item3D


@export var _boost_amount: float = 20.0
@export var _turn_mult: float = 0.5


func _ready() -> void:
	instigator.item_boost = _boost_amount
	instigator.turn_mult = _turn_mult
	instigator._start_trick_boost()



func _on_lifetime_timeout() -> void:
	instigator.item_boost = 0.0
	instigator.turn_mult = 1.0
	queue_free()
