extends Control
class_name PlayerJoinDisplay


@export var _player_id_label: Label


func with_data(id: int) -> PlayerJoinDisplay:
	_player_id_label.text = "Player %s" % (id + 1)
	return self
