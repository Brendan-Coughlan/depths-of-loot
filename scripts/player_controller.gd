extends CharacterBody2D

@onready var player_animated_sprite := $AnimatedSprite2D

var movement_speed := 100
var last_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		last_direction = direction
		
		if abs(direction.x) > abs(direction.y):
			# Horizontal movement
			player_animated_sprite.flip_h = direction.x < 0
			player_animated_sprite.play("run_right")
		else:
			# Vertical movement
			if direction.y < 0:
				player_animated_sprite.play("run_up")
			else:
				player_animated_sprite.play("run_down")
	else:
		# Idle animations based on last direction
		if abs(last_direction.x) > abs(last_direction.y):
			player_animated_sprite.flip_h = last_direction.x < 0
			player_animated_sprite.play("idle_right")
		else:
			if last_direction.y < 0:
				player_animated_sprite.play("idle_up")
			else:
				player_animated_sprite.play("idle_down")
	
	velocity = direction * movement_speed
	move_and_slide()
