extends Item3D


@export var _bullet_body: CharacterBody3D
@export var _hurtbox: Hurtbox


func _ready() -> void:
	top_level = true
	_hurtbox.set_instigator(instigator)
	
	# Make the bullet look at the car in front
	var level: Level3D = LevelManager.get_child(0)
	# Get the race pos of instigator
	var race_pos: int = level.get_race_pos_from_car(instigator)
	# Get the car in front of instigator
	var car_in_front: CarController = level.get_car_from_race_position(race_pos - 1)
	
	# Don't make the bullet look at the car that spawned it (Only happens when there's only 1 player)
	if car_in_front != instigator:
		look_at(car_in_front.global_position, Vector3.UP)
	
	# Apply force to the bullet
	_bullet_body.velocity = -global_basis.z * 50.0


func _physics_process(_delta: float) -> void:
	_bullet_body.move_and_slide()


func _on_hurtbox_hit_hitbox(_hitbox: Hitbox) -> void:
	queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
