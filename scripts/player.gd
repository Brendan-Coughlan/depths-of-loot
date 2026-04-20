extends CharacterBody2D
class_name Player

var last_direction: Vector2 = Vector2.DOWN


func update_last_direction(direction: Vector2):
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = Vector2(sign(direction.x), 0)
		else:
			last_direction = Vector2(0, sign(direction.y))
