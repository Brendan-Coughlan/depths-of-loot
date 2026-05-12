extends State
class_name PlayerDeath

@export var player: CharacterBody2D
@export var player_sprite: AnimatedSprite2D

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player_sprite:
		play_death_animation()
		await player_sprite.animation_finished
		print("Player is dead")
	else:
		print("Player sprite not found")

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO
	
func play_death_animation() -> void:
	var dir : Vector2 = player.last_direction
	
	if abs(dir.x) > abs(dir.y):
		player_sprite.flip_h = dir.x < 0
		play_if_not_playing("death_right")
	else:
		if dir.y < 0:
			play_if_not_playing("death_up")
		else:
			play_if_not_playing("death_down")

func play_if_not_playing(anim: String) -> void:
	if player_sprite.animation != anim:
		player_sprite.play(anim)
