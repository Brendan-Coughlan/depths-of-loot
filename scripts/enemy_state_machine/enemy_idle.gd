extends State
class_name EnemyIdle

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

func enter():
	play_idle_animation()

func play_idle_animation() -> void:
	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("idle_right")
	else:
		if dir.y < 0:
			play_if_not_playing("idle_up")
		else:
			play_if_not_playing("idle_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
