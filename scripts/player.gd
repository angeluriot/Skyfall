extends CharacterBody2D
class_name Player


@export var max_speed: float;
@export var acceleration: float;
@export var friction: float;
@export var push_force: float;

const BLOCKED_THRESHOLD := 1.0

var reachable_objects: Array[RigidBody2D] = []
var selected_objects: Array[RigidBody2D] = []
var grab_offsets: Dictionary = {}


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
	hold()
	push(direction)
	move_and_slide()
	drive_selected(delta)


func push(direction: Vector2) -> void:
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var object := collision.get_collider()

		if object is RigidBody2D:
			var rigid_body := object as RigidBody2D
			var push_direction := -collision.get_normal()

			if direction.dot(push_direction) > 0.0:
				rigid_body.apply_central_force(push_direction * push_force)


func grab() -> void:
	if Input.is_action_just_pressed('grab'):
		for object in reachable_objects:
			if selected_objects.has(object):
				continue

			selected_objects.append(object)
			grab_offsets[object] = object.global_position - global_position
			add_collision_exception_with(object)
			object.select(self)

	elif Input.is_action_just_released('grab'):
		for object in selected_objects:
			remove_collision_exception_with(object)
			object.deselect()
		selected_objects.clear()
		grab_offsets.clear()


func hold() -> void:
	for object in selected_objects:
		var offset: Vector2 = grab_offsets[object]
		var desired := object.global_position - offset
		var correction := desired - global_position

		if correction.length() > BLOCKED_THRESHOLD:
			global_position = desired
			velocity = velocity.slide(correction.normalized())


func drive_selected(delta: float) -> void:
	for object in selected_objects:
		var offset: Vector2 = grab_offsets[object]
		var target := global_position + offset
		object.linear_velocity = (target - object.global_position) / delta


func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	reachable_objects.append(body)


func _on_area_2d_body_exited(body: RigidBody2D) -> void:
	reachable_objects.erase(body)
