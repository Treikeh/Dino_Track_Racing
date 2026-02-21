extends Item3D


@export var _physics_body: CharacterBody3D
@export var _hurtbox: Hurtbox
@export var _mesh: Node3D
@export var _destroy_vfx: GPUParticles3D


func _ready() -> void:
	top_level = true
	
	# Make the trash bag not collide with the instigator when it spawns, but allow it to collide
	# with it later. I'm sure this isn't the best solution, but it works.
	_hurtbox.set_instigator(instigator, false)
	await get_tree().create_timer(0.1).timeout
	_hurtbox.set_instigator(instigator, true)


func _physics_process(delta: float) -> void:
	# Move the physics body downwards
	_physics_body.velocity += Vector3.DOWN * 20.0 * delta
	_physics_body.move_and_slide()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	_mesh.hide()
	_destroy_vfx.restart()
	_hurtbox.set_monitoring.call_deferred(false)


func _on_destroy_vfx_finished() -> void:
	queue_free()
