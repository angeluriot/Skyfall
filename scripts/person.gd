extends RigidBody2D


enum Type {
	MAN_1,
	MAN_2,
	MAN_3,
	MAN_4,
	WOMAN_1,
	WOMAN_2,
	WOMAN_3,
	WOMAN_4
}

var selected: bool = false
var last_velocity_y: float = 0.0

@export var max_speed: float;
@export var type: Type;

@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var collision := $CollisionShape2D as CollisionShape2D
@onready var particles := $GPUParticles2D as GPUParticles2D


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_body_entered)
	sprite.play(Type.find_key(type).to_lower())


func _physics_process(_delta: float) -> void:
	last_velocity_y = linear_velocity.y


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not Global.has_fall_ended and state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed


func select() -> void:
	sprite.material.set_shader_parameter('outline_width', 1.0)
	selected = true


func deselect() -> void:
	sprite.material.set_shader_parameter('outline_width', 0.0)
	selected = false


func _on_fall_ended() -> void:
	physics_material_override.bounce = 0.2
	gravity_scale = 1.0
	linear_velocity.y = Global.SPEED * Global.PIXEL_PER_METER


func _on_body_entered(body: Node) -> void:
	if not Global.has_fall_ended:
		return

	if body is AnimatableBody2D and abs(last_velocity_y) > Global.DEATH_SPEED:
		Global.deaths += 1
		explode()

	if body.has_method('is_soft') and body.is_soft():
		return

	if body is RigidBody2D:
		var other_velocity_y: float = body.last_velocity_y if 'last_velocity_y' in body else body.linear_velocity.y
		if abs(last_velocity_y - other_velocity_y) > Global.DEATH_SPEED:
			Global.deaths += 1
			explode()


func explode() -> void:
	sprite.hide()
	collision.set_deferred('disabled', true)
	particles.reparent(get_parent())
	particles.emitting = true
	particles.get_node('ExplosionSound').play()
