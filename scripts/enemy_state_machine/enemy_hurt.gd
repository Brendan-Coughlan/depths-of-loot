extends State
class_name EnemyHurt

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var health: HealthComponent

func enter() -> void:
	if enemy == null or enemy_sprite == null or health == null:
		Transitioned.emit(self, "idle")
		return

	health.invulnerable = true

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	play_hurt_animation()

	await enemy_sprite.animation_finished

	health.invulnerable = false

	if enemy.target != null:
		Transitioned.emit(self, "chase")
	else:
		Transitioned.emit(self, "idle")

func play_hurt_animation() -> void:
	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		enemy_sprite.play("hurt_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			enemy_sprite.play("hurt_up")
		else:
			enemy_sprite.play("hurt_down")
