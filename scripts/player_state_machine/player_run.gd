extends State
class_name PlayerRun

@export var player: Player
@export var player_sprite: AnimatedSprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		Transitioned.emit(self, "attack")

func enter() -> void:
	play_run_animation()

func physics_update(delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		# Update shared last direction
		player.update_last_direction(direction)

		# Apply movement
		player.velocity = direction.normalized() * player.movement_speed * delta
		player.move_and_slide()

		# Update animation
		play_run_animation()
	else:
		player.velocity = Vector2.ZERO
		Transitioned.emit(self, "idle")

func play_run_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)
