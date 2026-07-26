extends RigidBody2D


var selected: bool = false

@export var min_default_rotation_speed: float;
@export var max_default_rotation_speed: float;
@export var max_speed: float;
@export var max_angular_speed: float;
@export var min_bounce_speed: float;
@export var min_bounce_volume_db: float;
@export var max_bounce_volume_db: float;

var last_speed: float = 0.0

@onready var rotation_speed: float = Utils.get_rotation_speed(min_default_rotation_speed, max_default_rotation_speed)
@onready var sprite := $Sprite2D as Sprite2D
@onready var bounce_sound := $BounceSound as AudioStreamPlayer2D


func is_soft() -> bool:
	return true


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node) -> void:
	var t := clampf((last_speed - min_bounce_speed) / (max_speed - min_bounce_speed), 0.0, 1.0)
	bounce_sound.volume_db = lerpf(min_bounce_volume_db, max_bounce_volume_db, t)
	bounce_sound.play()


func _physics_process(_delta: float) -> void:
	last_speed = linear_velocity.length()

	if not selected and not Global.has_fall_ended:
		apply_torque(rotation_speed)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not Global.has_fall_ended and state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

	state.angular_velocity = clamp(state.angular_velocity, -max_angular_speed, max_angular_speed)


func _on_fall_ended() -> void:
	physics_material_override.bounce = 0.5
	gravity_scale = 1.0
	linear_velocity.y = Global.SPEED * Global.PIXEL_PER_METER


func select() -> void:
	sprite.material.set_shader_parameter("outline_width", 1.0)
	selected = true
	angular_velocity = 0.0


func deselect() -> void:
	sprite.material.set_shader_parameter("outline_width", 0.0)
	selected = false
	rotation_speed = randf_range(-max_default_rotation_speed, max_default_rotation_speed)

