extends Node

signal fall_ended

const PIXEL_PER_METER: float = 2.0

var altitude: float = 2000.0
var speed: float = 300.0
var has_fall_ended: bool = false
var deaths: int = 0


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if not has_fall_ended and altitude - speed * delta <= 0:
		altitude = 0.0
		end_fall()

	if not has_fall_ended:
		altitude -= speed * delta


func end_fall() -> void:
	has_fall_ended = true
	emit_signal('fall_ended')
	var timer := Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.connect('timeout', Callable(self, '_on_after_end'))
	get_tree().current_scene.add_child(timer)
	timer.start()


func _on_after_end() -> void:
	if deaths > 0:
		print(deaths, " deaths!")
	else:
		print("No deaths!")
