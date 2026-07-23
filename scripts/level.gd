extends Node2D


var entities: Array[RigidBody2D] = []

@onready var boundaries: Node2D = $Boundaries


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)

	entities.assign($Entities/People.get_children())
	entities.append_array($Entities/Objects/Soft.get_children())
	entities.append_array($Entities/Objects/Hard.get_children())
	entities.append($Player)


func _process(delta: float) -> void:
	pass


func _on_fall_ended() -> void:
	boundaries.queue_free()

	for entity in entities:
		entity.linear_velocity = Vector2(0.0, Global.speed * Global.PIXEL_PER_METER)
