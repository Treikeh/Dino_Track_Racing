extends SubViewportContainer


signal all_materials_loaded


const MAX_MATERIAL_LOADS_PER_FRAME: int = 3

@export var _mesh: MeshInstance3D

var _materials_loaded_this_frame: int = 0
var _materials: Array[String] = []
var _completed_materials: Array[String] = []


func _ready() -> void:
	get_files_in_folder("res://")


func get_files_in_folder(folder_path: String) -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(folder_path)
	for file: String in files:
		# Ignore dotfiles
		if file.begins_with("."):
			continue
		
		# Get all folders
		if file.ends_with("/"):
			var new_folder_path: String = folder_path + file
			# Recursively go through every folder
			get_files_in_folder(new_folder_path)
		# Get all materials
		elif file.ends_with("mat.tres"):
			var material_path: String = folder_path + file
			_materials.append(material_path)


func _process(_delta: float) -> void:
	if _materials.is_empty():
		return
	
	# Stop when all materials have been loaded
	if _completed_materials.size() >= _materials.size():
		all_materials_loaded.emit()
		return
	
	# Load all materials
	for i: int in _materials.size():
		# Get path of the material
		var material_path: String = _materials[i]
		# Check if material has been spawned before
		if _completed_materials.has(material_path):
			continue
		
		# Spawn material
		_load_material(material_path)
		
		# Add material to list of completed materials
		_completed_materials.append(material_path)
		
		# Stop after MAX_MATERIAL_LOADS_PER_FRAME amount of materials have been loaded
		_materials_loaded_this_frame += 1
		if _materials_loaded_this_frame >= MAX_MATERIAL_LOADS_PER_FRAME:
			_materials_loaded_this_frame = 0
			print(" ")
			return


func _load_material(material_path: String) -> void:
	print(material_path)
	var mat: Material = load(material_path)
	_mesh.material_override = mat
