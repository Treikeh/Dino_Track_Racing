extends Node


@warning_ignore_start("unused_signal")
signal car_positions_updated(car_positions: Array[int])
signal lap_changed(car_id: int, lap: int)


var player_count: int = 1
