extends State
class_name PlayerIdle

@export var player: Player
@export var player_sprite: AnimatedSprite2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		Transitioned.emit(self, "attack")

func enter():
	play_idle_animation()
		
func physics_update(_delta: float):
	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		player.update_last_direction(direction)
		Transitioned.emit(self, "run")
	else:
		play_idle_animation()
			
func play_idle_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("idle_right")
	else:
		if dir.y < 0:
			play_if_not_playing("idle_up")
		else:
			play_if_not_playing("idle_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)
