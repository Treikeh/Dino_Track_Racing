extends PathFollow3D


func _on_trigger_area_area_entered(area: Area3D) -> void:
	if area.owner is TrackFollow:
		var track_follow: TrackFollow = area.owner
		track_follow.entered_checkpoint()
