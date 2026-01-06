extends Node
# Autoload script to manage level loading/unloading
# This script is designed so replace a normal "main" scene setup.
# The problem I've had with the main scene system is that when testing differnt scenes i couldn't use
# the "Run Current Scene" (F6) function, because they might be reliant on the existence of the main
# scene. This meant that I conld only use the "Run project" (F5) function and had to go into the main
# scene and change which level was loaded every time I wanted to test a new/different level. This
# script (along with other autoload scripts) allows me to always have ceritan global functions (like
# level loading) avliable when testing.


const LOADING_SCREEN_SCENE: PackedScene = preload("res://gui/loading_screen/loading_screen.tscn")

var _loading_screen: LoadingScreen


func _ready() -> void:
	# Add the loading screen to the world
	_loading_screen = LOADING_SCREEN_SCENE.instantiate()
	# Call deffered so that the loadin screen ends up at the bottom of the scene tree, which will
	# make it appear on top of all other control nodes.
	get_tree().root.add_child.call_deferred(_loading_screen)
	
	_hijack_main_scene()


# Make the main scene a child of this node. This is to give this node full control of how to
# handle level loading/unloading.
func _hijack_main_scene() -> void:
	var current_scene: Node = get_tree().current_scene
	current_scene.reparent.call_deferred(self)


func load_level(level_path: String) -> void:
	# Check if the level exists
	if not ResourceLoader.exists(level_path):
		push_error("ERROR: %s path is not a valid level" % level_path)
		return
	
	# Show the loading screen
	_loading_screen.fade_in()
	await _loading_screen.fully_visible
	
	# Remove old level
	_unload_level()
	# Add new level
	var new_level: Node = load(level_path).instantiate()
	# Call deffered so that unloading levels can finish properly before adding the new level
	add_child.call_deferred(new_level)
	
	# Hide loading loading screen
	_loading_screen.fade_out()


func _unload_level() -> void:
	# Remove every player input controller
	for child: Node in Globals.viewports_container.get_children():
		remove_child(child)
		child.queue_free()
	
	# Remove level
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
