extends Resource
class_name ItemResource


@export var name: String = "Item"
@export var rarity: int = 1
## The minimum required race position that a car has to be at in order to get the item.
@export var min_positoin: int = 0
@export var icon: Texture2D
@export var scene: PackedScene
