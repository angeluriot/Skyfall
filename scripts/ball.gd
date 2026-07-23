extends RigidBody2D


var selected: bool = false

@export var min_rotation_speed: float;
@export var max_rotation_speed: float;

@onready var rotation_speed: float = Utils.get_rotation_speed(min_rotation_speed, max_rotation_speed)


func _physics_process(_delta: float) -> void:
	if not selected:
		apply_torque(rotation_speed)
