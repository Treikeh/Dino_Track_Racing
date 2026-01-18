extends RayCast3D


@export var _ray_end_offset: Vector3 = Vector3(0.0, -10.0, 0.0)
@export var _shadow_texture: Texture2D
@export var _shadow_decal: Decal


func _ready() -> void:
	_shadow_decal.texture_albedo = _shadow_texture


func _process(_delta: float) -> void:
	target_position = to_local(global_position + _ray_end_offset)
	
	if is_colliding():
		# Set position of decal
		var collision_point: Vector3 = get_collision_point()
		_shadow_decal.global_position = collision_point
		
		# Set scale of decal
		var distance: float = global_position.distance_to(collision_point)
		_shadow_decal.scale = Vector3.ONE * distance
	
	_shadow_decal.visible = is_colliding()
