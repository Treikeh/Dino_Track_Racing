extends Node3D


@export var _ray_end_offset: Vector3 = Vector3(0.0, -10.0, 0.0)
@export var _shadow_texture: Texture2D
@export var _shadow_dir_ray: RayCast3D
@export var _shadow_decal: Decal


func _ready() -> void:
	_shadow_decal.texture_albedo = _shadow_texture


func _process(_delta: float) -> void:
	_shadow_dir_ray.target_position = _shadow_dir_ray.to_local(global_position + _ray_end_offset)
	
	if _shadow_dir_ray.is_colliding():
		_shadow_decal.global_position = _shadow_dir_ray.get_collision_point()
	
	_shadow_decal.visible = _shadow_dir_ray.is_colliding()
