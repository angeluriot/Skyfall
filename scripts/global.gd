extends Node

signal fall_ended

const PIXEL_PER_METER: float = 3.0

var altitude: float = 2000.0
var speed: float = 300.0
var fallen: bool = false


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if not fallen and altitude - speed * delta <= 0.0:
		altitude = 0.0
		fallen = true
		emit_signal('fall_ended')

	if not fallen:
		altitude -= speed * delta
