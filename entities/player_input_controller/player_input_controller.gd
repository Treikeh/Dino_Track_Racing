extends Control
class_name PlayerInputController
## This class in responsible for allowing a player to control a car

@export_group("Car")
@export var _cam_follow_speed: float = 6.0
@export var _fov_lerp_speed: float = 2.5
@export var _fov_curve: Curve
@export var _cam: Camera3D
@export var _orientation: Node3D
@export var _id_label: Label3D

@export_group("HUD")
@export var _speedometer: PanelContainer
@export var _position_panel: PanelContainer
@export var _next_lap_panel: Control
@export var _item_panel: PanelContainer
@export var _countdown_panel: PanelContainer
@export var _wrong_way_panel: Container

@export_group("Debug")
@warning_ignore("unused_private_class_variable")
@export var _debug_label: Label

var _finished_all_laps: bool = false
var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _car_controller: CarController
var _track_follow: TrackFollow

var _ui_scale_factor: float = 1.0
var _cpu: PlayerCpuController


# Add after instatiate (instatiate().with_data(.., ..)) to setup controller data
func with_data(
		id: int,
		car_controller: CarController,
		track_follow: TrackFollow
) -> PlayerInputController:
	_player_id = id
	_car_controller = car_controller
	_track_follow = track_follow
	return self


func _ready() -> void:
	# Create new input actions (if they don't exist)
	Globals.set_up_player_inputs(_player_id)
	
	# Connect to car signals
	#NOTE: Could also be in the with_data() function, but it looks nicer here
	_car_controller.item_picked_up.connect(_on_car_item_picked_up)
	
	# Connect to trak follow signals
	#NOTE: This could also be in the with_data() function
	_track_follow.lap_changed.connect(_on_lap_changed)
	_track_follow.finished_all_laps.connect(_on_finished_all_laps)
	
	_id_label.text = "P%s" % (_player_id + 1)
	_orientation.global_position = _car_controller.global_position
	
	# Set up hud
	_position_panel.update_lap_label(1, _track_follow.total_laps)
	
	await get_tree().process_frame
	_scale_ui_elements()
	_on_lap_changed(1)
	
	if _player_id > 0:
		_add_cpu_controller()


func _input(event: InputEvent) -> void:
	# Disable player input when the player has finished the last lap
	if _finished_all_laps:
		return
	
	_throttle_input = Input.get_axis(
			"reverse%s" % _player_id,
			"accelerate%s" % _player_id
	)
	_turn_input = Input.get_axis(
			"turn_r%s" % _player_id,
			"turn_l%s" % _player_id
	)
	
	# Drift input
	if event.is_action_pressed("drift%s" % _player_id):
		_car_controller.try_dirft()
	elif event.is_action_released("drift%s" % _player_id):
		_car_controller.release_drift()
	
	# Use item input
	if event.is_action_pressed("use_held_item%s" % _player_id):
		_car_controller.use_held_item()
		_item_panel.used_item()
	
	_car_controller.throttle = _throttle_input
	_car_controller.turn_input = _turn_input


func _process(delta: float) -> void:
	# Change fov based on speed
	var desired_fov: float = _fov_curve.sample(_car_controller.speed_khm)
	_cam.fov = lerpf(_cam.fov, desired_fov, _fov_lerp_speed * delta)
	
	var drive_dir: float = _car_controller.global_basis.z.dot(_track_follow.global_basis.z)
	_wrong_way_panel.update(drive_dir)
	
	_speedometer.update(_car_controller.speed_khm)


func _physics_process(delta: float) -> void:
	# Make the camera follow the car controller
	var target_pos: Vector3 = _car_controller.global_position
	_id_label.global_position = target_pos + Vector3(0.0, 1.0, 0.0)
	_id_label.look_at(_get_look_at_pos())
	
	var target_quat: Quaternion = _id_label.quaternion
	_orientation.global_position = _orientation.global_position.lerp(target_pos, _cam_follow_speed * delta)
	_orientation.quaternion = _orientation.quaternion.slerp(target_quat, 4.0 * delta)


func _get_look_at_pos() -> Vector3:
	var car_pos: Vector3 = _car_controller.global_position
	var car_vel: Vector3 = _car_controller.linear_velocity
	var car_dir: Vector3 = -_car_controller.global_basis.z
	return car_pos + (car_dir * (3.0 + (4.0 * _throttle_input))) + car_vel


#region UI signal functions

func _scale_ui_elements() -> void:
	var window_height: float = get_window().size.y
	var view_height: float = size.y
	
	_ui_scale_factor = view_height / window_height
	var ui_scale: Vector2 = Vector2.ONE * _ui_scale_factor
	
	_item_panel.scale = ui_scale
	_next_lap_panel.scale = ui_scale
	_position_panel.scale = ui_scale
	_speedometer.scale = ui_scale
	_countdown_panel.scale = ui_scale
	_wrong_way_panel.scale = ui_scale


func on_car_positions_updated(car_positions: Array[int]) -> void:
	# Get the position the this player is in the array
	var race_pos: int = car_positions.find(_player_id) + 1
	_position_panel.update_race_pos(race_pos)


func _on_lap_changed(lap: int) -> void:
	_next_lap_panel.update(lap, _track_follow.total_laps)
	_position_panel.update_lap_label(lap, _track_follow.total_laps)
	
	# Show the next lap panel and move it up and down form the screen
	_next_lap_panel.show()
	# Save the default positoin so it can be used to reset it after the tween has finished
	var default_pos: Vector2 = _next_lap_panel.global_position
	
	# Where the tween should start and end
	var tween_down_pos: Vector2 = default_pos + (_next_lap_panel.size * _ui_scale_factor)
	_next_lap_panel.global_position = tween_down_pos
	# Set start rotation
	const ROTATION_OFFSET: float = 30.0
	_next_lap_panel.rotation_degrees = -ROTATION_OFFSET
	
	# Start tweening panel
	const TWEEN_DURATION: float = 1.5
	var tween: Tween = create_tween()
	# Move up
	var tween_up_pos: Vector2 = default_pos + (_next_lap_panel.size * 0.35 * _ui_scale_factor)
	tween.tween_property(_next_lap_panel, "global_position", tween_up_pos, 0.5)
	# Rotate
	tween.tween_property(_next_lap_panel, "rotation_degrees", ROTATION_OFFSET, TWEEN_DURATION)
	# Move down
	tween.tween_property(_next_lap_panel, "global_position", tween_down_pos, 0.5)
	
	# Hide and reset after tween has finished
	await tween.finished
	_next_lap_panel.hide()
	_next_lap_panel.rotation_degrees = 0.0
	_next_lap_panel.global_position = default_pos


func _on_finished_all_laps(_car_id: int) -> void:
	_finished_all_laps = true
	_countdown_panel.update_label("FINISHED")
	# Add ai controller


func _add_cpu_controller() -> void:
	if not _cpu:
		_cpu = PlayerCpuController.new(_car_controller, _track_follow)
		add_child(_cpu)


func _on_car_item_picked_up(item: ItemResource) -> void:
	_item_panel.picked_up_item(item)


func on_countdown_updated(seconds_left: int) -> void:
	_countdown_panel.update_secs_left(seconds_left)

#endregion
