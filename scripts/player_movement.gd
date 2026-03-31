extends CharacterBody2D

@onready var player_controller := $PlayerController
@onready var player_animated_sprite := $AnimatedSprite2D

var movement_speed := 5000
var last_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	var new_state = player_controller.States.RUNNING if direction != Vector2.ZERO else player_controller.States.IDLE

	player_controller.set_state(new_state, direction)
		
	if direction != Vector2.ZERO:
		velocity = direction * movement_speed * delta
	else:
		velocity = Vector2.ZERO
		
		move_and_slide()
