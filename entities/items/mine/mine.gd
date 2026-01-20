extends Item3D


@export var _explosion: Node3D
@export var _explosion_hurtbox: Hurtbox
@export var _ground_ray: RayCast3D

var _is_armed: bool = false


func _ready() -> void:
	top_level = true
	
	_explosion.hide()
	_explosion_hurtbox.set_instigator(instigator, true)
	
	_move_mine_to_ground()
	
	# Arm the mine after a short duration so that it won't be triggered when it spawns
	await get_tree().create_timer(0.2).timeout
	_is_armed = true


func _move_mine_to_ground() -> void:
	_ground_ray.to_local(global_position + Vector3(0.0, -50.0, 0.0))
	_ground_ray.force_raycast_update()
	if _ground_ray.is_colliding():
		global_position = _ground_ray.get_collision_point()
		#TODO: Aligin mine to the ground


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
