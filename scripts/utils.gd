extends Node


func ratio(value: float, value_min: float, value_max: float) -> float:
	return clampf((value - value_min) / (value_max - value_min), 0.0, 1.0)


func get_rotation_speed(min_rotation_speed: float, max_rotation_speed: float) -> float:
	if randf() < 0.5:
		return randf_range(min_rotation_speed, max_rotation_speed)

	return randf_range(-max_rotation_speed, -min_rotation_speed)
