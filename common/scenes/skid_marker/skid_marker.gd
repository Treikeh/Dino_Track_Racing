extends RayCast3D


@export var _mat: Material
@export var _mesh: MeshInstance3D
@export var _makrer: Marker3D

var _is_active: bool = false
var _mark: ImmediateMesh
var _verts: Array = []


func _ready() -> void:
	_mark = ImmediateMesh.new()
	_mesh.mesh = _mark


func _process(_delta: float) -> void:
	if is_colliding() and _is_active:
		_makrer.global_position = get_collision_point() + (get_collision_normal() * 0.05)
		_verts.append([
			_makrer.global_position + global_basis.z * 0.1,
			_makrer.global_position + -global_basis.z * 0.1,
			
			_makrer.global_position + global_basis.z * 0.1,
			_makrer.global_position + -global_basis.z * 0.1,
		])
	
		# Create a new surface mesh
		_mark.clear_surfaces()
		_mark.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, _mat)
		for i: int in _verts.size():
			var points: Array = _verts[i]
			_mark.surface_add_vertex(points[0])
			_mark.surface_add_vertex(points[1])
			_mark.surface_add_vertex(points[2])
			_mark.surface_add_vertex(points[3])
		_mark.surface_end()


func start_making_marks() -> void:
	_verts.clear()
	_is_active = true


func stop_making_marks() -> void:
	_is_active = false
