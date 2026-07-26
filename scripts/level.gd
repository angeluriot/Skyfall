extends Node2D


const MIN_WIND_VOLUME_DB: float = -60.0
const MAX_WIND_VOLUME_DB: float = -5.0
const MIN_MUSIC_VOLUME_DB: float = -80.0
const MAX_MUSIC_VOLUME_DB: float = -20.0

@onready var wind_player := $Wind as AudioStreamPlayer
@onready var music_player := $Music as AudioStreamPlayer


func _ready() -> void:
	var packed_scene := load('res://scenes/levels/level_%d.tscn' % Global.current_level) as PackedScene
	var entities := packed_scene.instantiate()
	$EntitiesContainer.add_child(entities)

	Global.fall_ended.connect(_on_fall_ended)

	wind_player.volume_db = MIN_WIND_VOLUME_DB
	music_player.volume_db = MIN_MUSIC_VOLUME_DB
	var win_tween := create_tween()
	win_tween.tween_property(wind_player, 'volume_db', MAX_WIND_VOLUME_DB, 1.0)

	var music_tween := create_tween()
	music_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	music_tween.tween_property(music_player, 'volume_db', MAX_MUSIC_VOLUME_DB, 8.0)


func _on_fall_ended() -> void:
	var wind_tween := create_tween()
	wind_tween.tween_property(wind_player, 'volume_db', MIN_WIND_VOLUME_DB, 2.0)
	wind_tween.tween_callback(wind_player.queue_free)

	var music_tween := create_tween()
	music_tween.tween_property(music_player, 'volume_db', MIN_MUSIC_VOLUME_DB, 2.0)
	music_tween.tween_callback(music_player.queue_free)
