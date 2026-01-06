extends Node


@warning_ignore_start("unused_signal")
signal car_positions_updated(car_positions: Array[int])
signal lap_changed(car_id: int, lap: int)


var player_count: Array[int] = [1, 0, 2, 7]
# Container that will hold all the player cameras
var viewports_container: GridContainer


func _ready() -> void:
	# Spawn viewports container
	viewports_container = GridContainer.new()
	get_tree().root.add_child.call_deferred(viewports_container)
	
	# Set up viewports container
	viewports_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewports_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewports_container.add_theme_constant_override("h_separation", 0)
	viewports_container.add_theme_constant_override("v_separation", 0)
