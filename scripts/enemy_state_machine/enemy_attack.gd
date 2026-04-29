extends State
class_name EnemyAttack

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var attack_cooldown: float = 0.8

var can_attack: bool = true


func enter() -> void:
	setup_references()

	if enemy == null:
		push_warning("EnemyAttack: enemy is null.")
		return

	if enemy_sprite != null:
		if not enemy_sprite.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			enemy_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

	if enemy.target == null:
		enemy.find_player()

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	update_attack_direction()


func physics_update(_delta: float) -> void:
	if enemy == null:
		setup_references()
		return

	if enemy.target == null:
		enemy.find_player()

		if enemy.target == null:
			Transitioned.emit(self, "idle")
			return

	var distance := enemy.global_position.distance_to(enemy.target.global_position)

	if distance > enemy.attack_range:
		Transitioned.emit(self, "chase")
		return

	if distance > 1.0:
		update_attack_direction()

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	if can_attack:
		attack()


func attack() -> void:
	if enemy == null or enemy.target == null:
		return

	can_attack = false

	play_attack_animation()

	if enemy.target.has_method("take_damage"):
		enemy.target.take_damage(enemy.attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func exit() -> void:
	if enemy != null:
		enemy.velocity = Vector2.ZERO


func update_attack_direction() -> void:
	if enemy == null or enemy.target == null:
		return

	var direction := enemy.target.global_position - enemy.global_position

	var horizontal_threshold := 12.0
	var vertical_dead_zone := 10.0

	if abs(direction.x) > horizontal_threshold:
		enemy.last_direction = Vector2(sign(direction.x), 0)
		return

	if abs(direction.y) > vertical_dead_zone:
		enemy.last_direction = Vector2(0, sign(direction.y))


func setup_references() -> void:
	if enemy == null:
		enemy = owner as Enemy

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")


func play_attack_animation() -> void:
	if enemy == null or enemy_sprite == null:
		return

	var dir := enemy.last_direction
	var anim := "attack_down"

	if abs(dir.x) > 0:
		enemy_sprite.flip_h = dir.x < 0
		anim = "attack_right"
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			anim = "attack_up"
		else:
			anim = "attack_down"

	enemy_sprite.play(anim)
	enemy_sprite.frame = 0


func _on_animation_finished() -> void:
	if enemy == null or enemy.target == null:
		return

	var distance := enemy.global_position.distance_to(enemy.target.global_position)

	if distance > enemy.attack_range:
		Transitioned.emit(self, "chase")
