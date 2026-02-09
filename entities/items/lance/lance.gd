extends Item3D


@export var _hurtbox: Hurtbox
@export var _speed_boost_curve: Curve
@export var _turn_mult: float = 0.9


func _ready() -> void:
	_hurtbox.set_instigator(instigator)
	instigator.turn_mult = _turn_mult


func _physics_process(_delta: float) -> void:
	instigator.item_boost = _speed_boost_curve.sample(instigator.speed_khm)


func _on_lifetime_timeout() -> void:
	instigator.item_boost = 0.0
	instigator.turn_mult = 1.0
	queue_free()
