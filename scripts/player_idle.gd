extends State
class_name PlayerIdle

@export var player_sprite: AnimatedSprite2D
var last_direction: Vector2 = Vector2.DOWN

func physics_update(_delta: float):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
	if direction != Vector2.ZERO:
		if direction.x != 0:
			last_direction = Vector2(sign(direction.x), 0)
		elif direction.y != 0:
			last_direction = Vector2(0, sign(direction.y))
		Transitioned.emit(self, "run")
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			player_sprite.flip_h = last_direction.x < 0
			player_sprite.play("idle_right")
		else:
			player_sprite.play("idle_up" if last_direction.y < 0 else "idle_down")
