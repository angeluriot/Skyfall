extends CharacterBody2D
class_name Player


var reachable_entities: Array[RigidBody2D] = []
var selected_entities: Array[RigidBody2D] = []
var selected_offset: Dictionary[RigidBody2D, Vector2] = {}
var selected_repel: Dictionary[RigidBody2D, Vector2] = {}
var safe := false

@export var max_speed: float;
@export var acceleration: float;
@export var friction: float;
@export var push_force: float;
@export var grab_min_repel: float;
@export var grab_max_repel: float;

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var soft_objects_countainer := %Entities/Objects/Soft as Node2D


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector('left','right','up','down')

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

	grab()
	push(direction)
	move_and_slide()
	fix_velocity()
	follow(delta)
	update_outline()


func grab() -> void:
	if Input.is_action_just_pressed('grab'):
		for entity in reachable_entities:
			select_entity(entity)
			selected_entities.append(entity)
			selected_offset[entity] = entity.global_position - global_position
			selected_repel[entity] = Vector2.ZERO

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


func fix_velocity() -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if not selected_entities.has(collision.get_collider()):
			velocity = velocity.slide(collision.get_normal())


func update_outline() -> void:
	var old_safe = safe
	var soft_objects: Array[RigidBody2D] = []
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
	entity.rotation_speed = randf_range(-entity.max_rotation_speed, entity.max_rotation_speed)
