extends RigidBody2D


var grabbed_by: Player = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not grabbed_by:
		global_rotation += 0.5 * delta


func select(player: Player) -> void:
	($Sprite2D as Sprite2D).material.set_shader_parameter("outline_width", 1.0)
	grabbed_by = player

func deselect() -> void:
	($Sprite2D as Sprite2D).material.set_shader_parameter("outline_width", 0.0)
	grabbed_by = null
