extends Area3D
class_name Hitbox
## Area that can get hit by a Hurtbox


signal hit
signal invulnerability_ended


@export var _invulnerability_timer: Timer


func take_damage() -> void:
	# Don't take damage when invulnerable
	if _invulnerability_timer.is_stopped():
		_invulnerability_timer.start()
		hit.emit()


func _on_invulnerability_timer_timeout() -> void:
	invulnerability_ended.emit()
