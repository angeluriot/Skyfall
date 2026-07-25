extends Node

signal fall_ended

const SPEED := 300.0
const PIXEL_PER_METER := 1.3
const DEATH_SPEED := 100.0

var altitude := 2000.0
var has_fall_ended := false
var deaths := 0
var current_level := 1


func _ready() -> void:
	pass


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
	match level:
		1:
			altitude = 2000.0
		2:
			altitude = 3000.0
		3:
			altitude = 4000.0

	has_fall_ended = false
	deaths = 0
	current_level = level
	print(current_level)
	get_tree().reload_current_scene()
