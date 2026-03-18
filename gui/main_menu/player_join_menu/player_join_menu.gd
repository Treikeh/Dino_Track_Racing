extends Control


signal menu_closed(menu: Control)


const PLAYER_JOIN_ENTRY_SCENE: PackedScene = preload("res://gui/main_menu/player_join_menu/join_entry/player_join_entry.tscn")


@export var _player_display_grid: GridContainer
@export var _start_game_progress_bar: Range
@export var _engine_sfx: AudioStreamPlayer

var _all_players_ready: bool = false
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
	
	# Don't allow the game to start if not all players are ready
	if not _all_players_ready:
		return
	
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
	player_label.player_readied_up.connect(_on_player_readied_up)
	player_label.player_unreadiedy_up.connect(_on_player_readied_up)
	player_label.player_removed.connect(_on_player_removed)
	
	_on_player_readied_up()
	
	# Change how many columns the player display grid container should have when a new player joins
	var columns: int = ceili(sqrt(_connected_players.size()))
	_player_display_grid.columns = columns
	
	# Show start game progress bar when the first player joins
	if not _start_game_progress_bar.visible:
		_start_game_progress_bar.visible = true
	
	_engine_sfx.play()


func _on_player_readied_up() -> void:
	# Check if all players are ready
	for id: int in _connected_players.size():
		var player_join_entry: PlayerJoinEntry = _player_display_grid.get_child(id)
		if not player_join_entry.is_ready:
			_all_players_ready = false
			return
		
		_all_players_ready = true


func _on_player_removed(id: int) -> void:
	var index: int = _connected_players.find(id)
	_connected_players.pop_at(index)
	_player_display_grid.get_child(index).queue_free()
	
	if _connected_players.size() > 0:
		var columns: int = ceili(sqrt(_connected_players.size()))
		_player_display_grid.columns = columns
	else:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
		menu_closed.emit(self)


func _start_level() -> void:
	# Rest the players dict
	Globals.players.clear()
	# Add all the new players to the players dict
	for i: int in _connected_players.size():
		var player_join_entry: PlayerJoinEntry = _player_display_grid.get_child(i)
		var id: int = player_join_entry._player_id
		Globals.players[id] = Globals.PlayerData.new(player_join_entry.current_hat)
	
	LevelManager.load_level("res://levels/Level_01/level_01.tscn")
