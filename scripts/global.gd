extends Node

signal fall_ended

const PIXEL_PER_METER: float = 2.0

var altitude: float = 2000.0
var speed: float = 300.0
var has_fall_ended: bool = false


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if not has_fall_ended and altitude - speed * delta <= 0:
		altitude = 0.0
		has_fall_ended = true
		emit_signal('fall_ended')

	if not has_fall_ended:
		altitude -= speed * delta
