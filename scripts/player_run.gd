extends State
class_name PlayerRun

@onready var player: CharacterBody2D = $"../.."
@export var player_sprite: AnimatedSprite2D
@export var movement_speed : int = 5000

func enter():
	print(player)

func physics_update(_delta: float):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if direction != Vector2.ZERO:
		player.velocity = direction * movement_speed * _delta
		
		if abs(direction.x) > abs(direction.y):
			player_sprite.flip_h = direction.x < 0
			player_sprite.play("run_right")
		else:
			player_sprite.play("run_up" if direction.y < 0 else "run_down")
		
		player.move_and_slide()
	else:
		Transitioned.emit(self, "idle")
