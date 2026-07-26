extends GPUParticles2D


const FADE_TIME: float = 0.3

var offset: Vector2 = Vector2.ZERO

@onready var camera := %Player/Camera2D as Camera2D


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)


func _physics_process(_delta: float) -> void:
	if Global.has_fall_ended:
		global_position = camera.get_screen_center_position() + offset


func _on_fall_ended() -> void:
	offset = global_position - camera.get_screen_center_position()
	var tween := create_tween()
	tween.tween_property(self, 'modulate:a', 0.0, FADE_TIME)
