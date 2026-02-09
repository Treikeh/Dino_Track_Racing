extends Control


@export var _lap_label: Label
@export var _dino_root: Control
@export var _dino_image: TextureRect
@export var _anim_curve: CurveXYZTexture

var _tween_duration: float = 2.0
var _tween: Tween
var _x_value: float = 0.0
var _y_value: float = 0.0
var _z_value: float = 0.0


func _ready() -> void:
	hide()
	size.y = _dino_image.size.y


func _process(_delta: float) -> void:
	_dino_root.position.x = _anim_curve.curve_x.sample(_x_value)
	_dino_root.position.y = _anim_curve.curve_y.sample(_y_value)
	_dino_root.rotation_degrees = _anim_curve.curve_z.sample(_z_value)


func update(lap: int, total_laps: int) -> void:
	_lap_label.text = "%s/%s" % [lap, total_laps]
	
	if _tween:
		_tween.kill()
	
	_x_value = 0.0
	_y_value = 0.0
	_z_value = 0.0
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.parallel().tween_property(self, "_x_value", 1.0, _tween_duration)
	_tween.parallel().tween_property(self, "_y_value", 1.0, _tween_duration)
	_tween.parallel().tween_property(self, "_z_value", 1.0, _tween_duration)
	_tween.tween_callback(hide)
