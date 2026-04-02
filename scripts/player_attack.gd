extends State
class_name PlayerAttack

@export var player_sprite: AnimatedSprite2D
var last_direction: Vector2 = Vector2.DOWN

func enter():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
	if direction != Vector2.ZERO:
		last_direction = direction
	
	if abs(last_direction.x) > abs(last_direction.y):
		player_sprite.flip_h = last_direction.x < 0
		player_sprite.play("attack_right")
	else:
		player_sprite.play("attack_up" if last_direction.y < 0 else "attack_down")
	await player_sprite.animation_finished
	Transitioned.emit(self, "idle")

func physics_update(_delta: float):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
	if direction != Vector2.ZERO:
		last_direction = direction
