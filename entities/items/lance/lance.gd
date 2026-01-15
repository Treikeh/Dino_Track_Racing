extends Item3D


@export var _hurtbox: Hurtbox


func _ready() -> void:
	_hurtbox.set_instigator(instigator)


func _on_lifetime_timeout() -> void:
	queue_free()
