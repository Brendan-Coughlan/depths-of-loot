extends State
class_name EnemyAttack

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var enemy_hitboxes: Array[CollisionShape2D]
@export var attack_cooldown: float = 0.8
@export var attack_exit_buffer: float = 12.0

var can_attack: bool = true
var attacking: bool = false


func enter() -> void:
	setup_references()

	if enemy == null:
		push_warning("EnemyAttack: enemy is null.")
		return

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

	var distance := get_attack_distance()

	if distance > enemy.attack_range + attack_exit_buffer and not attacking:
		Transitioned.emit(self, "chase")
		return

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	if can_attack and not attacking:
		attack()
		
func get_attack_distance() -> float:
	var enemy_origin := enemy.get_node_or_null("AttackOrigin") as Marker2D
	var player_target := enemy.target.get_node_or_null("TargetPoint") as Marker2D

	if enemy_origin == null or player_target == null:
		return enemy.global_position.distance_to(enemy.target.global_position)

	var root_distance := enemy.global_position.distance_to(enemy.target.global_position)
	var marker_distance := enemy_origin.global_position.distance_to(player_target.global_position)

	return min(root_distance, marker_distance)


func attack() -> void:
	if enemy == null or enemy_sprite == null:
		return

	can_attack = false
	attacking = true

	update_attack_direction()

	var dir := enemy.last_direction
	var hitbox_index := get_hitbox_index(dir)

	play_attack_animation()

	if hitbox_index != -1:
		enemy_hitboxes[hitbox_index].disabled = false

	await enemy_sprite.animation_finished

	if hitbox_index != -1:
		enemy_hitboxes[hitbox_index].disabled = true

	attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func exit() -> void:
	disable_all_hitboxes()

	if enemy != null:
		enemy.velocity = Vector2.ZERO

	attacking = false


func update_attack_direction() -> void:
	if enemy == null or enemy.target == null:
		return

	var enemy_origin := enemy.get_node("AttackOrigin") as Marker2D
	var player_target := enemy.target.get_node("TargetPoint") as Marker2D

	var direction := player_target.global_position - enemy_origin.global_position

	#print(
		#"Enemy Y:", enemy.global_position.y,
		#" Player Y:", enemy.target.global_position.y,
		#" Direction:", direction
	#)
	
	if direction.length() < 4.0:
		return # keep previous last_direction
	
	print("Fixed Direction:", direction)

	if abs(direction.x) > abs(direction.y):
		enemy.last_direction = Vector2(sign(direction.x), 0)
	else:
		enemy.last_direction = Vector2(0, sign(direction.y))


func get_hitbox_index(dir: Vector2) -> int:
	if enemy_hitboxes.size() < 4:
		push_warning("EnemyAttack: enemy_hitboxes needs 4 CollisionShape2D nodes.")
		return -1

	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			return 1
		else:
			return 0
	else:
		if dir.y < 0:
			return 2
		else:
			return 3


func disable_all_hitboxes() -> void:
	for hitbox in enemy_hitboxes:
		if hitbox != null:
			hitbox.disabled = true


func setup_references() -> void:
	if enemy == null:
		enemy = owner as Enemy

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")


func play_attack_animation() -> void:
	if enemy == null or enemy_sprite == null:
		return

	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		enemy_sprite.play("attack_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			enemy_sprite.play("attack_up")
		else:
			enemy_sprite.play("attack_down")

	enemy_sprite.frame = 0
