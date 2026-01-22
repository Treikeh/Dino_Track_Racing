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
@export var _position_label: Label
@export var _speedometer: Label
@export var _lap_label: Label
@export var _countdown_label: Label
@export var _item_image: TextureRect
@export var _wrong_way_panel: Container
@export var _next_lap_panel: Container
@export var _next_lap_panel_label: Label

@export_group("Debug")
@warning_ignore("unused_private_class_variable")
@export var _debug_label: Label

var _finished_all_laps: bool = false
var _player_id: int = 0
var _throttle_input: float
var _turn_input: float
var _car_controller: CarController
var _track_follow: TrackFollow
var _countdown_tween: Tween


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
	_lap_label.text = "1/%s" % _track_follow.total_laps
	_orientation.global_position = _car_controller.global_position
	
	_item_image.hide()
	_next_lap_panel.hide()


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
		_item_image.hide()
	
	_car_controller.throttle = _throttle_input
	_car_controller.turn_input = _turn_input


func _process(delta: float) -> void:
	# Change fov based on speed
	var desired_fov: float = _fov_curve.sample(_car_controller.speed_khm)
	_cam.fov = lerpf(_cam.fov, desired_fov, _fov_lerp_speed * delta)
	
	var track_drive_dir: float = _car_controller.global_basis.z.dot(_track_follow.global_basis.z)
	var driving_wrong_way: bool = track_drive_dir > -0.3
	_wrong_way_panel.visible = not driving_wrong_way
	
	_speedometer.text = "%s kmh" % int(snappedf(_car_controller.speed_khm, 1.0))
	$Hud/SpeedometerPanel/HBoxContainer/TextureProgressBar.value = _car_controller.speed_khm


func _physics_process(delta: float) -> void:
	# Make the camera follow the car controller
	var target_pos: Vector3 = _car_controller.global_position
	_id_label.global_position = target_pos + Vector3(0.0, 1.0, 0.0)
	_id_label.look_at(_get_look_at_pos())
	
	var target_quat: Quaternion = _id_label.quaternion
	_orientation.global_position = _orientation.global_position.lerp(target_pos, _cam_follow_speed * delta)
	_orientation.quaternion = _orientation.quaternion.slerp(target_quat, 4.0 * delta)
	
	# Make the car automatically move when the player has finished the last lap
	#TODO: Replace with a simple AI that follow the track
	if _finished_all_laps:
		_car_controller.throttle = 1.0
		_car_controller.turn_input = 1.0
		_car_controller.stop_drift()


func _get_look_at_pos() -> Vector3:
	var car_pos: Vector3 = _car_controller.global_position
	var car_vel: Vector3 = _car_controller.linear_velocity
	var car_dir: Vector3 = -_car_controller.global_basis.z
	return car_pos + (car_dir * (3.0 + (4.0 * _throttle_input))) + car_vel


#region UI signal functions

func on_car_positions_updated(car_positions: Array[int]) -> void:
	# Get the position the this player is in the array
	var car_pos: int = car_positions.find(_player_id) + 1
	# Turn position into a string
	var car_pos_string: String = str(car_pos)
	# Change the car pos string to match the fonts values if in 1 - 3 place
	# See positions font image and the ASCII character codes positions (48 - 60)
	match car_pos:
		1:
			car_pos_string = ":"
		2:
			car_pos_string = ";"
		3:
			car_pos_string = "<"
	# Set position label text
	_position_label.text = car_pos_string


func _on_lap_changed(lap: int) -> void:
	_lap_label.text = "%s/%s" % [lap, _track_follow.total_laps]
	
	# Make the next lap panel move and rotate at the bottom of the screen
	_next_lap_panel.show()
	const ROTATION_OFFSET: float = 30.0
	const TWEEN_DURATION: float = 1.5
	var start_y_pos: float = size.y + _next_lap_panel.size.y
	# Reset panel
	_next_lap_panel.rotation_degrees = -ROTATION_OFFSET
	_next_lap_panel.position.y = start_y_pos
	_next_lap_panel_label.text = _lap_label.text
	
	# Start tweening panel
	var tween: Tween = create_tween()
	# Move up
	var end_y_pos: float = (size.y / 2.0) + _next_lap_panel.size.y
	tween.tween_property(_next_lap_panel, "position:y", end_y_pos, 0.5)
	# Rotate
	tween.tween_property(_next_lap_panel, "rotation_degrees", ROTATION_OFFSET, TWEEN_DURATION)
	tween.parallel().tween_property(_next_lap_panel, "position:y", end_y_pos - 10.0, TWEEN_DURATION)
	# Move down
	tween.tween_property(_next_lap_panel, "position:y", start_y_pos, 0.5)
	
	# Hide panel after tween is finished
	tween.tween_callback(_next_lap_panel.hide)


func _on_finished_all_laps(_car_id: int) -> void:
	_finished_all_laps = true
	_update_countdown_label("FINISHED", 2.0)


func _on_car_item_picked_up(item: ItemResource) -> void:
	_item_image.show()
	_item_image.texture = item.icon


func on_countdown_updated(seconds_left: int) -> void:
	_countdown_label.show()
	if seconds_left <= 0:
		_update_countdown_label("GO!", 2.0)
	else:
		_update_countdown_label(str(seconds_left))


func _update_countdown_label(
		new_text: String,
		visible_duration: float = 0.6,
		fade_duration: float = 0.2,
) -> void:
	# Reset countdown label
	_countdown_label.text = new_text
	_countdown_label.show()
	_countdown_label.modulate = Color.TRANSPARENT
	
	# Stop tween if allready running
	if _countdown_tween:
		_countdown_tween.stop()
	
	_countdown_tween = create_tween()
	_countdown_tween.tween_property(_countdown_label, "modulate", Color.WHITE, fade_duration)
	_countdown_tween.tween_interval(visible_duration)
	_countdown_tween.tween_property(_countdown_label, "modulate", Color.TRANSPARENT, fade_duration)
	_countdown_tween.tween_callback(_countdown_label.hide)

#endregion
