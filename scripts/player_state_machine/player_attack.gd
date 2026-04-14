extends State
class_name PlayerAttack

@export var player: Player
@export var player_sprite: AnimatedSprite2D
@export var player_hitbox: CollisionShape2D

func enter() -> void:
	# Update last_direction if player is pressing a movement key
	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		player.update_last_direction(direction)

	play_attack_animation()
	player_hitbox.disabled = false
	await player_sprite.animation_finished
	player_hitbox.disabled = true
	Transitioned.emit(self, "idle")

func physics_update(_delta: float) -> void:
	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		player.update_last_direction(direction)

func play_attack_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("attack_right")
	else:
		if dir.y < 0:
			play_if_not_playing("attack_up")
		else:
			play_if_not_playing("attack_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)
