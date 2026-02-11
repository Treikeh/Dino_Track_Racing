extends Item3D


const METEOR_SCENE: PackedScene = preload("uid://51nggv4278od")


func _ready() -> void:
	# Get the current level
	var level: Level3D = LevelManager.current_level
	
	# Get the first car
	var target_car: CarController = level.get_car_from_race_position(0)
	
	for i: int in range(0, 10):
		_spawn_meteor(target_car)


func _on_timer_timeout() -> void:
	queue_free()


func _spawn_meteor(target_car: CarController) -> void:
	await get_tree().create_timer(randf_range(0.0, 1.0)).timeout
	
	const R: float = 5.0
	var rand_pos: Vector3 = Vector3(randf_range(-R, R), randf_range(-R, R), randf_range(-R, R))
	var prediction: Vector3 = target_car.linear_velocity.normalized() * 12.5
	var target_pos: Vector3 = target_car.global_position + rand_pos + prediction
	var meteor: Meteor = METEOR_SCENE.instantiate().with_data(instigator, target_pos)
	add_child(meteor)
