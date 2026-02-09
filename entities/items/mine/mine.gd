extends Item3D


@export var _physics_body: CharacterBody3D
@export var _explosion: Node3D
@export var _explosion_hurtbox: Hurtbox

var _is_armed: bool = false


func _ready() -> void:
	top_level = true
	
	_explosion.hide()
	_explosion_hurtbox.set_instigator(instigator, true)
	
	# Arm the mine after a short duration so that it won't be triggered when it spawns
	await get_tree().create_timer(0.1).timeout
	_is_armed = true


func _physics_process(delta: float) -> void:
	# Move the mine down to the ground
	_physics_body.velocity += Vector3.DOWN * 20.0 * delta
	_physics_body.move_and_slide()


func _explode() -> void:
	_explosion.show()
	_trigger_explosion_hurtbox()
	
	# Despawn after the explosion effects ends
	await get_tree().create_timer(1.5).timeout
	queue_free()


# Enable the hurtbox for a short duration before disabling it again
func _trigger_explosion_hurtbox() -> void:
	_explosion_hurtbox.set_monitoring.call_deferred(true)
	await get_tree().create_timer(0.2).timeout
	_explosion_hurtbox.set_monitoring.call_deferred(false)


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body is CarController and _is_armed:
		_explode()
