extends RigidBody2D
class_name PlayerEnd


var sprite: AnimatedSprite2D
var collision: CollisionShape2D
var particles: GPUParticles2D
var last_velocity_y: float = 0.0


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_body_entered)


func _physics_process(_delta: float) -> void:
	last_velocity_y = linear_velocity.y


func init() -> void:
	sprite = $AnimatedSprite2D
	collision = $CollisionShape2D
	particles = $GPUParticles2D


func _on_body_entered(body: Node) -> void:
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
