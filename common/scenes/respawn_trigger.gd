extends Area3D


@export var _track: Path3D


func _on_body_entered(body: Node3D) -> void:
	if body is CarController:
		_respawn_car(body)


func _respawn_car(car: CarController) -> void:
	# Disable movement
	car.set_movement_state(CarController.MovementState.DISABLED)
	
	await get_tree().create_timer(0.5).timeout
	
	car.linear_velocity = Vector3.ZERO
	
	var local_pos: Vector3 = car.last_ground_pos * _track.global_transform
	var closest_track_point: Vector3 = _track.curve.get_closest_point(local_pos)
	var respawn_point: Vector3 = closest_track_point + Vector3(0.0, 5.0, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(car, "global_position", respawn_point, 1.5)
	
	car.set_movement_state(CarController.MovementState.NORMAL)
