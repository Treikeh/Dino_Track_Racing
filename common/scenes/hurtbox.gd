extends Area3D
class_name Hurtbox
## Area that deals damage to Hitboxes


signal hit_hitbox(hitbox: Hitbox)


var _can_hit_instigator: bool = false
# The node that made/owns this hurtbox.
# Used to filter collisions so that only objects that doesn't own it can get hit by it.
var _instigator: Node


func set_instigator(instigator: Node, can_hit_instigator: bool = false) -> void:
	_instigator = instigator
	_can_hit_instigator = can_hit_instigator


func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox and (not _instigator.is_ancestor_of(area) or _can_hit_instigator):
		area.take_damage()
		hit_hitbox.emit(area)
