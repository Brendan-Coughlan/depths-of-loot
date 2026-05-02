extends State
class_name EnemyDeath

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	
	if enemy_sprite:
		play_death_animation()
		await enemy_sprite.animation_finished
		print("Enemy is dead")
		enemy.queue_free()
		
	else:
		print("Enemy sprite not found")

func physics_update(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO

func play_death_animation() -> void:
	var dir : Vector2 = enemy.last_direction
	
	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("death_right")
	else:
		if dir.y < 0:
			play_if_not_playing("death_up")
		else:
			play_if_not_playing("death_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
