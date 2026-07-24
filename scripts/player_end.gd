extends RigidBody2D
class_name PlayerEnd


var outline_removed := false


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1000
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node) -> void:
	if not outline_removed:
		($AnimatedSprite2D as AnimatedSprite2D).material.set_shader_parameter('outline_width', 0.0)
		outline_removed = true
