extends Node3D
class_name Item3D


var instigator: CarController


func with_data(_instigator: CarController) -> Item3D:
	instigator = _instigator
	return self
