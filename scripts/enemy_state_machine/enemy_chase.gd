extends State
class_name EnemyChase

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D


func enter() -> void:
	if enemy == null:
		enemy = owner as Enemy

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")

	if enemy != null and enemy.target == null:
		enemy.find_player()

	play_run_animation()


func physics_update(_delta: float) -> void:
	if enemy == null:
		return

	if enemy.target == null:
		enemy.find_player()
		return

	var distance := enemy.global_position.distance_to(enemy.target.global_position)

	# Too far away: go back to idle
	if distance > enemy.detection_range:
		Transitioned.emit(self, "idle")
		return

	# Close enough: attack
	if distance <= enemy.attack_range:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		Transitioned.emit(self, "attack")
		return

	var direction := (enemy.target.global_position - enemy.global_position).normalized()

	if direction == Vector2.ZERO:
		enemy.velocity = Vector2.ZERO
		return

	enemy.velocity = direction * enemy.movement_speed
	enemy.update_last_direction(direction)
	enemy.move_and_slide()

	play_run_animation()


func exit() -> void:
	if enemy != null:
		enemy.velocity = Vector2.ZERO


func play_run_animation() -> void:
	if enemy == null or enemy_sprite == null:
		return

	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")


func play_if_not_playing(anim: String) -> void:
	if enemy_sprite == null:
		return

	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
