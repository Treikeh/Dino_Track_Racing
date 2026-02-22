extends Node3D


signal explosion_finished


@export var _animation_player: AnimationPlayer


func play() -> void:
	_animation_player.play("anim")
	AudioWorld3d.play_sound(Sfx3D.Type.EXPLOSION, global_position)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	explosion_finished.emit()
