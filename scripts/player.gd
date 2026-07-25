extends CharacterBody2D
class_name Player


const CAMERA_SMOOTHING_SPEED: float = 1.0
const CAMERA_SMOOTHING_FADE_TIME: float = 3.0

var is_to_the_left: bool = false
var reachable_entities: Array[RigidBody2D] = []
var selected_entities: Array[RigidBody2D] = []
var selected_offset: Dictionary[RigidBody2D, Vector2] = {}
var selected_repel: Dictionary[RigidBody2D, Vector2] = {}
var safe := false
var wants_idle := false
var grab_direction := Vector2.ZERO

@export var max_speed: float;
@export var acceleration: float;
@export var friction: float;
@export var push_force: float;
@export var grab_min_repel: float;
@export var grab_max_repel: float;

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var collision_shape := $CollisionShape2D as CollisionShape2D
@onready var grab_area := $Area2D as Area2D
@onready var camera := $Camera2D as Camera2D
@onready var soft_objects_countainer: Node2D = null


func _ready() -> void:
	Global.fall_ended.connect(_on_fall_ended)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = CAMERA_SMOOTHING_SPEED


func _physics_process(delta: float) -> void:
	if Global.has_fall_ended:
		return

	if soft_objects_countainer == null:
		soft_objects_countainer = get_parent().get_node('EntitiesContainer/Entities/Objects/Soft') as Node2D

	var direction := Input.get_vector('left','right','up','down')

	animate(direction)
	move(direction, delta)
	grab(direction)
	push(direction)

	move_and_slide()

	fix_velocity()
	update_camera_smoothing()
	follow(delta)
	update_outline()


func _on_frame_changed() -> void:
	if wants_idle and animated_sprite.animation == 'move' and animated_sprite.frame in [0, 3]:
		var frame := animated_sprite.frame
		animated_sprite.play('idle')
		animated_sprite.frame = (frame + 1) % 6
		wants_idle = false


func _on_fall_ended() -> void:
	camera.position_smoothing_enabled = false

	for entity in selected_entities:
		deselect_entity(entity)
		selected_entities.clear()
		selected_offset.clear()
		selected_repel.clear()

	animate(Vector2.ZERO, true)

	var rigid_body = PlayerEnd.new()
	rigid_body.global_transform = global_transform
	rigid_body.linear_velocity = Vector2(velocity.x, Global.SPEED * Global.PIXEL_PER_METER)
	rigid_body.collision_layer = collision_layer
	rigid_body.collision_mask = collision_mask
	rigid_body.lock_rotation = true

	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 0.2
	rigid_body.physics_material_override = physics_material

	get_parent().add_child(rigid_body)

	for child in get_children():
		child.reparent(rigid_body)

	rigid_body.init()

	queue_free()


func animate(direction: Vector2, force: bool = false) -> void:
	# Grab case
	if not selected_entities.is_empty():
		wants_idle = false
		var grab_idle := direction == Vector2.ZERO
		var frame := animated_sprite.frame
		var old_animation := animated_sprite.animation
		var new_animation := ''

		if grab_direction.y > 0.0:
			new_animation = 'idle_down_grab' if grab_idle else 'move_down_grab'
		elif grab_direction.y < 0.0:
			new_animation = 'idle_up_grab' if grab_idle else 'move_up_grab'
		else:
			new_animation = 'idle_grab' if grab_idle else 'move_grab'

		if old_animation != new_animation:
			animated_sprite.play(new_animation)
			animated_sprite.frame = (frame + 1) % 6

		return

	# Animation
	if direction == Vector2.ZERO:
		if not force and animated_sprite.animation == 'move':
			wants_idle = true
		else:
			wants_idle = false
			animated_sprite.play('idle')
	elif direction.y > 0.0:
		wants_idle = false
		animated_sprite.play('move_down')
	elif direction.y < 0.0:
		wants_idle = false
		animated_sprite.play('move_up')
	else:
		wants_idle = false
		animated_sprite.play('move')

	# Flip and collisions
	var collision_shape_position = Vector2.ZERO
	var grab_area_position = Vector2.ZERO
	var collision_shape_rotation = 0.0
	var grab_area_rotation = 0.0

	if direction.y > 0.0:
		collision_shape_position = Vector2(-0.5, -1)
		grab_area_position = Vector2(7.5, 7.5)
		collision_shape_rotation = -45
		grab_area_rotation = -45

	elif direction.y < 0.0:
		collision_shape_position = Vector2(0, 0)
		grab_area_position = Vector2(7.5, -7.5)
		collision_shape_rotation = 45
		grab_area_rotation = 45

	else:
		collision_shape_position = Vector2(0, 2)
		grab_area_position = Vector2(12, 2)
		collision_shape_rotation = -90
		grab_area_rotation = -90

	if direction.x < 0.0:
		is_to_the_left = true
	elif direction.x > 0.0:
		is_to_the_left = false

	if is_to_the_left:
		animated_sprite.flip_h = true
		collision_shape_position.x = -collision_shape_position.x
		grab_area_position.x = -grab_area_position.x
		collision_shape_rotation = -collision_shape_rotation
		grab_area_rotation = -grab_area_rotation
	else:
		animated_sprite.flip_h = false

	collision_shape.position = collision_shape_position
	grab_area.position = grab_area_position
	collision_shape.rotation_degrees = collision_shape_rotation
	grab_area.rotation_degrees = grab_area_rotation


func move(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(
			direction * max_speed,
			acceleration * delta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			friction * delta
		)

	if Global.has_fall_ended:
		velocity.y += ProjectSettings.get_setting('physics/2d/default_gravity') * delta


func grab(direction: Vector2) -> void:
	if Input.is_action_just_pressed('grab'):
		for entity in reachable_entities:
			select_entity(entity)
			selected_entities.append(entity)
			selected_offset[entity] = entity.global_position - global_position
			selected_repel[entity] = Vector2.ZERO
		if not selected_entities.is_empty():
			grab_direction = direction

	elif Input.is_action_just_released('grab'):
		for entity in selected_entities:
			deselect_entity(entity)
		selected_entities.clear()
		selected_offset.clear()
		selected_repel.clear()


func push(direction: Vector2) -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var entity := collision.get_collider()

		if entity is RigidBody2D:
			var rigid_body := entity as RigidBody2D
			var push_direction := -collision.get_normal()

			if rigid_body in selected_entities:
				selected_repel[rigid_body] += push_direction * grab_min_repel
				if selected_repel[rigid_body].length() > grab_max_repel:
					selected_repel[rigid_body] = selected_repel[rigid_body].normalized() * grab_max_repel
			elif direction.dot(push_direction) > 0.0:
				rigid_body.apply_central_force(push_direction * push_force)


func follow(delta: float) -> void:
	for entity in selected_entities:
		var target := global_position + selected_offset[entity] + selected_repel[entity]
		entity.linear_velocity = (target - entity.global_position) / delta


func update_camera_smoothing() -> void:
	var time_left := Global.altitude / Global.SPEED
	var t := clampf(time_left / CAMERA_SMOOTHING_FADE_TIME, 0.0, 1.0)
	camera.position_smoothing_speed = CAMERA_SMOOTHING_SPEED / maxf(t, 0.001)


func fix_velocity() -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if not (collision.get_collider() is RigidBody2D and selected_entities.has(collision.get_collider())):
			velocity = velocity.slide(collision.get_normal())


func update_outline() -> void:
	var old_safe = safe
	var soft_objects: Array[RigidBody2D] = []

	if soft_objects_countainer == null:
		return

	soft_objects.assign(soft_objects_countainer.get_children())
	safe = Utils.is_person_safe(self, soft_objects, [])

	if safe != old_safe:
		animated_sprite.material.set_shader_parameter(
			'outline_width',
			1.0 if safe else 0.0
		)


func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	reachable_entities.append(body)


func _on_area_2d_body_exited(body: RigidBody2D) -> void:
	reachable_entities.erase(body)


func select_entity(entity: RigidBody2D) -> void:
	(entity.get_node('Sprite2D') as Sprite2D).material.set_shader_parameter("outline_width", 1.0)
	entity.selected = true
	entity.angular_velocity = 0.0


func deselect_entity(entity: RigidBody2D) -> void:
	(entity.get_node('Sprite2D') as Sprite2D).material.set_shader_parameter("outline_width", 0.0)
	entity.selected = false
	entity.rotation_speed = randf_range(-entity.max_default_rotation_speed, entity.max_default_rotation_speed)
