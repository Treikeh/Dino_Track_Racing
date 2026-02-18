extends Control


const PLAYER_JOIN_ENTRY_SCENE: PackedScene = preload("res://gui/main_menu/player_join_menu/join_entry/player_join_entry.tscn")


@export var _player_display_grid: GridContainer
@export var _start_game_progress_bar: Range
@export var _engine_sfx: AudioStreamPlayer

var _start_game_pressed: bool = false
var _start_game_player_id: int = -1
var _start_game_time: float = 0.0
# int = player id
var _connected_players: Array[int] = []


func _ready() -> void:
	_start_game_progress_bar.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !_connected_players.has(event.device):
		_add_player(event.device)
	# Start timer to start the level when a joined player presses ui_accept
	elif event.is_action_pressed("ui_accept") and _start_game_player_id == -1:
		_start_game_pressed = true
		_start_game_player_id = event.device
	
	# Stop timer when the player that wants to start the game releases the ui_accept button
	if event.is_action_released("ui_accept") and _start_game_pressed and event.device == _start_game_player_id:
		_start_game_pressed = false
		_start_game_player_id = -1


func _process(delta: float) -> void:
	if _start_game_pressed:
		_start_game_time += delta
		# Start game after a short while
		if _start_game_time >= 2.0:
			_start_level()
	elif _start_game_time > 0.0:
		_start_game_time -= delta
	_start_game_progress_bar.value = _start_game_time


func _add_player(player_id: int) -> void:
	_connected_players.append(player_id)
	
	var player_label: PlayerJoinEntry = PLAYER_JOIN_ENTRY_SCENE.instantiate().with_data(player_id)
	_player_display_grid.add_child(player_label)
	
	# Change how many columns the player display grid container should have when a new player joins
	var columns: int = ceili(sqrt(_connected_players.size()))
	_player_display_grid.columns = columns
	
	# Show start game progress bar when the first player joins
	if not _start_game_progress_bar.visible:
		_start_game_progress_bar.visible = true
	
	_engine_sfx.play()


func _start_level() -> void:
	# Rest the players dict
	Globals.players.clear()
	# Add all the new players to the players dict
	for player: int in _connected_players:
		Globals.players[player] = 0.0
	
	LevelManager.load_level("res://levels/Level_01/level_01.tscn")
