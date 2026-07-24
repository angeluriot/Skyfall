extends Node


func ratio(value: float, value_min: float, value_max: float) -> float:
	return clampf((value - value_min) / (value_max - value_min), 0.0, 1.0)


func get_circle_global_x_bounds(collision: CollisionShape2D) -> Vector2:
	var circle := collision.shape as CircleShape2D
	assert(circle != null)

	var transform := collision.global_transform
	var radius := circle.radius * 0.5

	var extent_x := radius * sqrt(
		transform.x.x * transform.x.x
		+ transform.y.x * transform.y.x
	)

	var center_x := transform.origin.x
	return Vector2(center_x - extent_x, center_x + extent_x)


func get_rectangle_global_x_bounds(collision: CollisionShape2D) -> Vector2:
	var rectangle := collision.shape as RectangleShape2D
	assert(rectangle != null)

	var half_size := rectangle.size * 0.5
	var transform := collision.global_transform

	var corners := [
		transform * Vector2(-half_size.x, -half_size.y),
		transform * Vector2( half_size.x, -half_size.y),
		transform * Vector2( half_size.x,  half_size.y),
		transform * Vector2(-half_size.x,  half_size.y),
	]

	var min_x: float = corners[0].x
	var max_x: float = corners[0].x

	for corner: Vector2 in corners:
		min_x = minf(min_x, corner.x)
		max_x = maxf(max_x, corner.x)

	return Vector2(min_x, max_x)


func get_global_x_bounds(body: RigidBody2D) -> Vector2:
	var collision := body.get_node('CollisionShape2D') as CollisionShape2D

	if collision.shape is CircleShape2D:
		return get_circle_global_x_bounds(collision)

	return get_rectangle_global_x_bounds(collision)


func is_person_above(person: PhysicsBody2D, object: RigidBody2D) -> bool:
	if person.global_position.y > object.global_position.y:
		return false

	var x_bounds := get_global_x_bounds(object)

	if person.global_position.x < x_bounds.x or person.global_position.x > x_bounds.y:
		return false

	return true


func is_person_below(person: PhysicsBody2D, object: RigidBody2D) -> bool:
	if person.global_position.y < object.global_position.y:
		return false

	var x_bounds := get_global_x_bounds(object)

	if person.global_position.x < x_bounds.x or person.global_position.x > x_bounds.y:
		return false

	return true


func is_person_safe(person: PhysicsBody2D, soft_objects: Array[RigidBody2D], hard_objects: Array[RigidBody2D]) -> bool:
	var output = false
	var closest_soft_object: RigidBody2D = null

	for soft_object in soft_objects:
		if is_person_above(person, soft_object):
			output = true
			if closest_soft_object == null or soft_object.global_position.y < closest_soft_object.global_position.y:
				closest_soft_object = soft_object

	if not output:
		return false

	for hard_object in hard_objects:
		if is_person_above(person, hard_object) and hard_object.global_position.y < closest_soft_object.global_position.y:
			return false

		if is_person_below(person, hard_object) and hard_object.global_position.y > closest_soft_object.global_position.y:
			return false

	return true


func get_rotation_speed(min_rotation_speed: float, max_rotation_speed: float) -> float:
	if randf() < 0.5:
		return randf_range(min_rotation_speed, max_rotation_speed)

	return randf_range(-max_rotation_speed, -min_rotation_speed)
