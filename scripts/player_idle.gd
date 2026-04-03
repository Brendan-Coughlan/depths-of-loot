extends State
class_name PlayerIdle

@export var player_sprite: AnimatedSprite2D
var last_direction: Vector2 = Vector2.DOWN

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		Transitioned.emit(self, "attack")

func enter():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
	if direction != Vector2.ZERO:
		last_direction = direction
		
	if abs(last_direction.x) > abs(last_direction.y):
		player_sprite.flip_h = last_direction.x < 0
		player_sprite.play("idle_right")
	else:
		player_sprite.play("idle_up" if last_direction.y < 0 else "idle_down")
		
func physics_update(_delta: float):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		
	if direction != Vector2.ZERO:
		last_direction = direction
		Transitioned.emit(self, "run")
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			player_sprite.flip_h = last_direction.x < 0
			player_sprite.play("idle_right")
		else:
			player_sprite.play("idle_up" if last_direction.y < 0 else "idle_down")
