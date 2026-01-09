extends Node3D
class_name Item3D


var instigator: Node


func with_data(_instigator: Node) -> Item3D:
	instigator = _instigator
	return self
