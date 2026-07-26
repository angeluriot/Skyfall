extends Node

signal fall_ended

const SPEED := 300.0
const PIXEL_PER_METER := 1
const DEATH_SPEED := 100.0
const SAFE_COLOR := Color('#0bde39')
const ALTITUDES := {
	1: 2500.0,
	2: 2000.0,
	3: 3000.0,
	4: 3000.0
}

var current_level := 4
var altitude: float = ALTITUDES[current_level]
var max_altitude := altitude
var has_fall_ended := false
var deaths := 0


func _physics_process(delta: float) -> void:
	if not has_fall_ended and altitude - SPEED * delta <= 0:
		altitude = 0.0
		end_fall()

	if not has_fall_ended:
		altitude -= SPEED * delta


func end_fall() -> void:
	has_fall_ended = true
	emit_signal('fall_ended')
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.connect('timeout', Callable(self, '_on_after_end'))
	get_tree().current_scene.add_child(timer)
	timer.start()


func _on_after_end() -> void:
	if deaths > 0:
		reset(current_level)
	else:
		reset(current_level + 1)


func reset(level: int) -> void:
	altitude = ALTITUDES[level]
	max_altitude = altitude
	has_fall_ended = false
	deaths = 0
	current_level = level
	get_tree().reload_current_scene()
