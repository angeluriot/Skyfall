extends RigidBody2D


var selected: bool = false

@export var min_default_rotation_speed: float;
@export var max_default_rotation_speed: float;
@export var max_speed: float;
@export var max_angular_speed: float;

@onready var rotation_speed: float = Utils.get_rotation_speed(min_default_rotation_speed, max_default_rotation_speed)


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)


func _physics_process(_delta: float) -> void:
	if not selected:
		apply_torque(rotation_speed)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

	state.angular_velocity = clamp(state.angular_velocity, -max_angular_speed, max_angular_speed)


func _on_fall_ended() -> void:
	physics_material_override.bounce = 0.5
