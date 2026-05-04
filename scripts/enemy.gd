extends CharacterBody2D
class_name Enemy

@export var enemy_state_machine: Node

@export var movement_speed: float = 80.0
@export var attack_range: float = 40.0
@export var attack_damage: int = 10
@export var detection_range: float = 150.0

@onready var health: HealthComponent = $HealthComponent

var target: Player
var last_direction: Vector2 = Vector2.DOWN
var is_dead: bool = false


func _ready() -> void:
	find_player()

	if health != null:
		if not health.damaged.is_connected(_on_damaged):
			health.damaged.connect(_on_damaged)

		if not health.died.is_connected(_on_died):
			health.died.connect(_on_died)
	else:
		push_warning("Enemy: HealthComponent not found.")


func find_player() -> void:
	target = get_tree().get_first_node_in_group("player") as Player


func update_last_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	if abs(direction.x) > abs(direction.y):
		last_direction = Vector2(sign(direction.x), 0)
	else:
		last_direction = Vector2(0, sign(direction.y))


func take_damage(amount: int = 10) -> void:
	if is_dead:
		return

	if health == null:
		push_warning("Enemy: Cannot take damage because HealthComponent is missing.")
		return

	health.take_damage(amount)


func _on_damaged(amount: int) -> void:
	if is_dead:
		return

	print("Enemy took damage:", amount)

	if enemy_state_machine != null:
		enemy_state_machine.on_child_transition(
			enemy_state_machine.current_state,
			"hurt"
		)


func _on_died() -> void:
	if is_dead:
		return

	is_dead = true

	velocity = Vector2.ZERO

	if enemy_state_machine != null:
		enemy_state_machine.on_child_transition(
			enemy_state_machine.current_state,
			"death"
		)
	else:
		queue_free()


func can_see_player() -> bool:
	if target == null:
		find_player()

	if target == null:
		return false

	var distance := global_position.distance_to(target.global_position)
	return distance <= detection_range


func is_player_in_attack_range() -> bool:
	if target == null:
		find_player()

	if target == null:
		return false

	var distance := global_position.distance_to(target.global_position)
	return distance <= attack_range


func get_direction_to_player() -> Vector2:
	if target == null:
		find_player()

	if target == null:
		return Vector2.ZERO

	return (target.global_position - global_position).normalized()
