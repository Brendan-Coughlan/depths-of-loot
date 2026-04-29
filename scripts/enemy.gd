extends CharacterBody2D
class_name Enemy

@export var enemy_state_machine: Node
@export var movement_speed: float = 80.0
@export var attack_range: float = 32.0
@export var attack_damage: int = 10

var target: Player
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	find_player()

func find_player() -> void:
	target = get_tree().get_first_node_in_group("player") as Player

	if target == null:
		push_warning("Enemy: No Player found in group 'player'.")

func update_last_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = Vector2(sign(direction.x), 0)
		else:
			last_direction = Vector2(0, sign(direction.y))

func take_damage() -> void:
	if enemy_state_machine == null:
		push_warning("Enemy: enemy_state_machine is not assigned.")
		return

	enemy_state_machine.on_child_transition(
		enemy_state_machine.current_state,
		"death"
	)
