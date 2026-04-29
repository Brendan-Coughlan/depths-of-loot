extends State
class_name EnemyIdle

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D


func enter() -> void:
	if enemy == null:
		enemy = owner as Enemy

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")

	if enemy != null and enemy.target == null:
		enemy.find_player()

	play_idle_animation()


func physics_update(_delta: float) -> void:
	if enemy == null:
		return

	if enemy.target == null:
		enemy.find_player()
		return

	var distance := enemy.global_position.distance_to(enemy.target.global_position)

	if distance <= enemy.detection_range:
		Transitioned.emit(self, "chase")


func play_idle_animation() -> void:
	if enemy == null or enemy_sprite == null:
		return

	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("idle_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			play_if_not_playing("idle_up")
		else:
			play_if_not_playing("idle_down")


func play_if_not_playing(anim: String) -> void:
	if enemy_sprite == null:
		return

	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
