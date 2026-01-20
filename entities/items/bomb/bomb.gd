extends Item3D


@export var _throw_force: float = 30.0
@export var _throw_dir: Node3D
@export var _bomb_body: RigidBody3D
@export var _explosion: Node3D
@export var _explosion_hurtbox: Hurtbox


func _ready() -> void:
	top_level = true
	
	_explosion.hide()
	_explosion_hurtbox.set_instigator(instigator, true)
	
	_bomb_body.apply_central_impulse(-_throw_dir.global_basis.z * _throw_force + instigator.linear_velocity)


func _explode() -> void:
	# Show explosion
	_explosion.global_position = _bomb_body.global_position
	_explosion.show()
	_trigger_explosion_hurtbox()
	
	# Disable bomb body
	_bomb_body.hide()
	_bomb_body.freeze = true
	
	# Despawn after explosion effect finishes
	await get_tree().create_timer(1.5).timeout
	queue_free()


# Enable the hurtbox for a short duration before disabling it again
func _trigger_explosion_hurtbox() -> void:
	_explosion_hurtbox.set_monitoring.call_deferred(true)
	await get_tree().create_timer(0.1).timeout
	_explosion_hurtbox.set_monitoring.call_deferred(false)


func _on_bomb_body_body_entered(_body: Node) -> void:
	_explode()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	_explode()
