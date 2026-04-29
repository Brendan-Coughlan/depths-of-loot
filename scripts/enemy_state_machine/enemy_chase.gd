extends State
class_name EnemyChase

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

func enter() -> void:
	if enemy.target == null:
		enemy.find_player()

	play_run_animation()

func physics_update(_delta: float) -> void:
	if enemy.target == null:
		enemy.find_player()
		return

	var direction := (enemy.target.global_position - enemy.global_position).normalized()

	if direction != Vector2.ZERO:
		enemy.velocity = direction * enemy.movement_speed
		enemy.update_last_direction(direction)

		if abs(direction.x) > abs(direction.y):
			enemy_sprite.flip_h = direction.x < 0
			enemy_sprite.play("run_right")
		else:
			enemy_sprite.flip_h = false
			enemy_sprite.play("run_up" if direction.y < 0 else "run_down")

		enemy.move_and_slide()

func play_run_animation() -> void:
	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
