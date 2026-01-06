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


# Input actions to copy and assign to each new player
var _input_actions: Array[String] = [
	"accelerate",
	"reverse",
	"turn_l",
	"turn_r",
	"drift",
]

## Crate new input actions for the player
func set_up_player_inputs(player_id: int) -> void:
	for action: String in _input_actions:
		var new_action: String = action + str(player_id)
		# Don't add the new action if it allready exists
		if InputMap.has_action(new_action):
			return
		
		# Get event related to the input action
		var action_events: Array = InputMap.action_get_events(action)
		
		InputMap.add_action(new_action)
		# Duplicate the old events and add them to the input action
		for event: InputEvent in action_events:
			var new_event: InputEvent = event.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
			new_event.device = player_id
			InputMap.action_add_event(new_action, new_event)
