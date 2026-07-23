extends Node2D


@export var stop_y: float;

@onready var ground: AnimatableBody2D = $Ground


func _ready() -> void:
	ground.position.y = stop_y + Global.altitude * Global.PIXEL_PER_METER


func _physics_process(_delta: float) -> void:
	ground.position.y = stop_y + Global.altitude * Global.PIXEL_PER_METER
