extends Node2D


func _ready() -> void:
	var packed_scene := load('res://scenes/levels/level_%d.tscn' % Global.current_level) as PackedScene
	var entities := packed_scene.instantiate()
	$EntitiesContainer.add_child(entities)
