extends Node3D


@export var _hover_speed: float = 1.0
@export var _hover_height: float = 0.5
@export var _rotation_speed: float = 30.0
@export var _disabled_duration: float = 5.0
@export var _items: Array[ItemResource] = []
@export var _mesh_root: Node3D
@export var _break_vfx: GPUParticles3D
@export var _disabled_timer: Timer

var _enabled: bool = true
var _time: float = 0.0


func _ready() -> void:
	_disabled_timer.wait_time = _disabled_duration


func _process(delta: float) -> void:
	# Make the box move up and down
	_time += delta
	_mesh_root.position.y = 1.25 + (sin(_time * _hover_speed) * _hover_height)
	_mesh_root.rotation_degrees.y += _rotation_speed * delta


func _give_car_random_item(car: CarController) -> void:
	# Get the total rarity of all items
	var weigth_sum: int = 0
	for item: ItemResource in _items:
		weigth_sum += item.weigth
	
	# Randomize the array so that the 
	# If I don't do this then the items that are at the start of the array are less likely to be
	# selected, even if they have a higher rarity.
	_items.shuffle()
	
	# Get the random value that the item is at
	var item_val: int = randi_range(0, weigth_sum)
	var item_sum: int = 0
	var car_pos: int = LevelManager.current_level.get_race_pos_from_car(car)
	for item: ItemResource in _items:
		item_sum += item.weigth
		if item_sum >= item_val:
			# Redo this function if the car is too far to get the item.
			if car_pos < item.min_positoin:
				_give_car_random_item(car)
				return
			car.pick_up_item(item)
			return


func _disable_box() -> void:
	_enabled = false
	_mesh_root.hide()
	_disabled_timer.start()


func _enable_box() -> void:
	_enabled = true
	_mesh_root.show()


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Check if the body is a car controller
	if _enabled and body is CarController:
		_give_car_random_item(body)
		_disable_box()
		_break_vfx.restart()


func _on_disabled_timer_timeout() -> void:
	_enable_box()
