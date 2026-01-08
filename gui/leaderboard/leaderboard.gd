extends Control


@export var _entry_container: Container


# Add all the entires to the leaderboard
func populate(time_taken: float) -> void:
	#TODO: Add support for AI/NPC character
	for player: int in Globals.player_count:
		var entry_label := Label.new()
		_entry_container.add_child(entry_label)
		entry_label.text = "Player %s: ------- %s" % [player, snappedf(time_taken, 0.01)]


func _on_main_menu_button_pressed() -> void:
	LevelManager.load_level("res://gui/main_menu/main_menu.tscn")
