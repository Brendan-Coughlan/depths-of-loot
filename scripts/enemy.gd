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

func _ready() -> void:
	find_player()

	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func _on_damaged(amount: int) -> void:
	print("Enemy took damage:", amount)

	if enemy_state_machine != null:
		enemy_state_machine.on_child_transition(
			enemy_state_machine.current_state,
			"hurt"
		)

func _on_died() -> void:
	if enemy_state_machine != null:
		enemy_state_machine.on_child_transition(
			enemy_state_machine.current_state,
			"death"
		)

func find_player() -> void:
	target = get_tree().get_first_node_in_group("player") as Player

func update_last_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = Vector2(sign(direction.x), 0)
		else:
			last_direction = Vector2(0, sign(direction.y))
