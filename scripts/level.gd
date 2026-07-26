extends Node2D


const MIN_VOLUME_DB: float = -60.0
const MAX_VOLUME_DB: float = -10.0

@onready var audio_player := $AudioStreamPlayer as AudioStreamPlayer


func _ready() -> void:
	var packed_scene := load('res://scenes/levels/level_%d.tscn' % Global.current_level) as PackedScene
	var entities := packed_scene.instantiate()
	$EntitiesContainer.add_child(entities)

	Global.fall_ended.connect(_on_fall_ended)

	audio_player.volume_db = MIN_VOLUME_DB
	var tween := create_tween()
	tween.tween_property(audio_player, 'volume_db', MAX_VOLUME_DB, 1.0)


func _on_fall_ended() -> void:
	var tween := create_tween()
	tween.tween_property(audio_player, 'volume_db', MIN_VOLUME_DB, 2.0)
	tween.tween_callback(audio_player.queue_free)
