extends Item3D


@export var _bullet_body: CharacterBody3D
@export var _hurtbox: Hurtbox


func _ready() -> void:
	top_level = true
	_hurtbox.set_instigator(instigator)
	_bullet_body.velocity = -global_basis.z * 10.0


func _physics_process(_delta: float) -> void:
	_bullet_body.move_and_slide()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	queue_free()
