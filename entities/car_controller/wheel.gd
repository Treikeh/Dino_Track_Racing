extends RayCast3D


@export var enable_steering: bool = false
@export var _radius: float = 0.2
@export var _mesh: Node3D


func _process(_delta: float) -> void:
	if is_colliding():
		_mesh.global_position = get_collision_point() + (global_basis.y * _radius)
	else:
		_mesh.position.y = target_position.y + _radius
