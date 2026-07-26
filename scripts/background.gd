extends Node2D


var offset: Vector2 = Vector2.ZERO
var clouds_1_stopped: bool = false
var clouds_2_stopped: bool = false

@export var stop_y: float;

@onready var camera := %Player/Camera2D as Camera2D
@onready var clouds_1 = $Clouds1 as GPUParticles2D
@onready var clouds_2 = $Clouds2 as GPUParticles2D
@onready var ground: AnimatableBody2D = $Ground


func _ready() -> void:
	ground.position.y = stop_y + Global.altitude * Global.PIXEL_PER_METER
	offset = clouds_1.global_position - camera.get_screen_center_position()


func _physics_process(_delta: float) -> void:
	ground.position.y = stop_y + Global.altitude * Global.PIXEL_PER_METER
	clouds_1.global_position = camera.get_screen_center_position() + offset
	clouds_2.global_position = camera.get_screen_center_position() + offset

	if Global.altitude <= 1100.0 and not clouds_1_stopped:
		clouds_1_stopped = true
		clouds_1.emitting = false

	if Global.altitude <= 1950.0 and not clouds_2_stopped:
		clouds_2_stopped = true
		clouds_2.emitting = false
