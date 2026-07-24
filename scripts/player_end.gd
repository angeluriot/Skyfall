extends RigidBody2D
class_name PlayerEnd


var outline_removed := false
var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var particles: GPUParticles2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_body_entered)


func init() -> void:
	sprite = $AnimatedSprite2D
	collision = $CollisionShape2D
	particles = $GPUParticles2D


func _on_body_entered(body: Node) -> void:
	if body is AnimatableBody2D:
		if abs(linear_velocity.y) > 150:
			Global.deaths += 1
			explode()

	if not outline_removed:
		($AnimatedSprite2D as AnimatedSprite2D).material.set_shader_parameter('outline_width', 0.0)
		outline_removed = true


func explode() -> void:
	sprite.hide()
	collision.set_deferred('disabled', true)
	particles.emitting = true
