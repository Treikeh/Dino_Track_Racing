extends Control


const PLAYER_JOIN_DISPALY_SCENE: PackedScene = preload("res://gui/main_menu/player_join_display/player_join_display.tscn")


@export var _player_display_container: GridContainer

var _connected_players: Array[int] = []


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !_connected_players.has(event.device):
		_add_player(event.device)
	
	if event.is_action_pressed("pause") and _connected_players.size() > 0:
		_start_level()


func _add_player(player_id: int) -> void:
	_connected_players.append(player_id)
	
	var player_label: PlayerJoinDisplay = PLAYER_JOIN_DISPALY_SCENE.instantiate().with_data(player_id)
	_player_display_container.add_child(player_label)
	
	# Change how many columns the player display grid container should have when a new player joins
	var columns: int = ceili(sqrt(_connected_players.size()))
	_player_display_container.columns = columns


func _start_level() -> void:
	Globals.player_count = _connected_players
	LevelManager.load_level("res://levels/dev/dev_level.tscn")
