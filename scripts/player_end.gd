extends RigidBody2D
class_name PlayerEnd


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
	if body is AnimatableBody2D and abs(linear_velocity.y) > Global.DEATH_SPEED:
		Global.deaths += 1
		explode()

	if body.has_method('is_soft') and body.is_soft():
		return

	if body.has_method('is_soft') and not body.is_soft():
		Global.deaths += 1
		explode()

	if body is RigidBody2D and abs(linear_velocity.y - body.linear_velocity.y) > Global.DEATH_SPEED:
		print(linear_velocity.y)
		print(body.linear_velocity.y)
		Global.deaths += 1
		explode()


func explode() -> void:
	sprite.hide()
	collision.set_deferred('disabled', true)
	particles.reparent(get_parent())
	particles.emitting = true
	particles.get_node('ExplosionSound').play()
