extends State
class_name PlayerHurt

@export var player: Player
@export var player_sprite: AnimatedSprite2D
@export var health: HealthComponent

func enter():
	health.invulnerable = true
	play_hurt_animation()
	await player_sprite.animation_finished
	health.invulnerable = false
	Transitioned.emit(self, "idle")

func play_hurt_animation() -> void:
	var dir := player.last_direction

	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("hurt_right")
	else:
		if dir.y < 0:
			play_if_not_playing("hurt_up")
		else:
			play_if_not_playing("hurt_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)
