extends GPUParticles2D


const FADE_TIME: float = 0.3

var offset: Vector2 = Vector2.ZERO

@onready var player_marker := %Player/Marker2D as Marker2D


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)


func _physics_process(_delta: float) -> void:
	if Global.has_fall_ended:
		global_position = player_marker.global_position + offset


func _on_fall_ended() -> void:
	offset = global_position - player_marker.global_position
	var tween := create_tween()
	tween.tween_property(self, 'modulate:a', 0.0, FADE_TIME)
