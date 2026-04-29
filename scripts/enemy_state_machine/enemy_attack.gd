extends State
class_name EnemyAttack

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var target: Node2D
@export var attack_range: float = 35.0
@export var attack_cooldown: float = 0.8
@export var damage: int = 10

var can_attack: bool = true

func enter() -> void:
	target = get_tree().get_first_node_in_group("player")
	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()
	play_attack_animation()

func physics_update(_delta: float) -> void:
	if target == null:
		Transitioned.emit(self, "idle")
		return

	var distance := enemy.global_position.distance_to(target.global_position)

	if distance > attack_range:
		Transitioned.emit(self, "chase")
		return

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	if can_attack:
		attack()

func attack() -> void:
	can_attack = false
	play_attack_animation()

	if target.has_method("take_damage"):
		target.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func play_attack_animation() -> void:
	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			play_if_not_playing("attack_left")
		else:
			play_if_not_playing("attack_right")
	else:
		if dir.y < 0:
			play_if_not_playing("attack_up")
		else:
			play_if_not_playing("attack_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
