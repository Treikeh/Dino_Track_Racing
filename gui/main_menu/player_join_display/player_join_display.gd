extends Control
class_name PlayerJoinDisplay


@export var _player_id_label: Label

var _player_id: int

func with_data(id: int) -> PlayerJoinDisplay:
	_player_id = id
	_player_id_label.text = "Player %s" % (id + 1)
	return self


func _ready() -> void:
	# Create input actions for this player
	Globals.set_up_player_inputs(_player_id)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drift%s" % _player_id):
		print("Player %s wants to start" % _player_id)
