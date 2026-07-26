extends Node

signal fall_ended

const SPEED := 300.0
const PIXEL_PER_METER := 1
const DEATH_SPEED := 350.0
const SUCCESS_COLOR := Color('#09d37c')
const FAIL_COLOR := Color('#d32940')
const TRANSITION_COVER_TIME := 0.5
const TRANSITION_REVEAL_TIME := 0.5
const TRANSITION_HOLD_TIME := 0.0
const ALTITUDES := {
	1: 2500.0,
	2: 2000.0,
	3: 3000.0,
	4: 3000.0,
	5: 4000.0,
	6: 2000.0,
	7: 4000.0,
	8: 3000.0,
	9: 7000.0,
	10: 10000.0
}

const PersonExplosionScene := preload('res://scenes/person_explosion.tscn')

var current_level := 1
var altitude: float = ALTITUDES[current_level]
var max_altitude := altitude
var has_fall_ended := false
var deaths := 0
var is_transitioning := false

var transition_layer: CanvasLayer
var transition_rect: Panel
var transition_style: StyleBoxFlat


func _ready() -> void:
	setup_transition()
	warmup_explosion()


func warmup_explosion() -> void:
	var explosion := PersonExplosionScene.instantiate() as GPUParticles2D
	explosion.position = Vector2(-100000, -100000)
	explosion.get_node('ExplosionSound').queue_free()
	add_child(explosion)
	explosion.emitting = true

	var timer := get_tree().create_timer(explosion.lifetime * (1.0 + explosion.process_material.lifetime_randomness) + 0.1)
	timer.timeout.connect(explosion.queue_free)



func setup_transition() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 128
	add_child(transition_layer)

	transition_style = StyleBoxFlat.new()
	transition_style.border_width_left = 1
	transition_style.border_width_top = 1
	transition_style.border_width_right = 1
	transition_style.border_width_bottom = 1
	transition_style.border_color = Color.BLACK

	transition_rect = Panel.new()
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_rect.visible = false
	transition_rect.add_theme_stylebox_override('panel', transition_style)
	transition_layer.add_child(transition_rect)

	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color('#00005840')

	var transition_shadow := Panel.new()
	transition_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_shadow.show_behind_parent = true
	transition_shadow.anchor_right = 1.0
	transition_shadow.anchor_bottom = 1.0
	transition_shadow.offset_left = -3.0
	transition_shadow.offset_top = -3.0
	transition_shadow.offset_right = 3.0
	transition_shadow.offset_bottom = 3.0
	transition_shadow.add_theme_stylebox_override('panel', shadow_style)
	transition_rect.add_child(transition_shadow)


func _physics_process(delta: float) -> void:
	if not has_fall_ended and altitude - SPEED * delta <= 0:
		altitude = 0.0
		end_fall()

	if not has_fall_ended:
		altitude -= SPEED * delta


func end_fall() -> void:
	has_fall_ended = true
	emit_signal('fall_ended')
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.connect('timeout', Callable(self, '_on_after_end'))
	get_tree().current_scene.add_child(timer)
	timer.start()


func _on_after_end() -> void:
	var success := current_level < 10 and deaths == 0
	var next_level := current_level + 1 if success else current_level
	play_transition(success, next_level)


func play_transition(success: bool, next_level: int) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	var size := get_viewport().get_visible_rect().size

	transition_style.bg_color = SUCCESS_COLOR if success else FAIL_COLOR
	transition_rect.size = size * 2.0
	transition_rect.position = Vector2(-size.x * 0.5, size.y)
	transition_rect.visible = true

	var covered_y := -size.y * 0.5
	var revealed_y := -size.y * 2.1

	var tween := create_tween()
	tween.tween_property(transition_rect, 'position:y', covered_y, TRANSITION_COVER_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: reset(next_level))
	tween.tween_interval(TRANSITION_HOLD_TIME)
	tween.tween_property(transition_rect, 'position:y', revealed_y, TRANSITION_REVEAL_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void:
		transition_rect.visible = false
		is_transitioning = false
	)


func reset(level: int) -> void:
	altitude = ALTITUDES[level]
	max_altitude = altitude
	has_fall_ended = false
	deaths = 0
	current_level = level
	get_tree().reload_current_scene()
