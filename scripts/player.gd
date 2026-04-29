extends CharacterBody2D
class_name Player

var last_direction: Vector2 = Vector2.DOWN

@onready var health: HealthComponent = $HealthComponent
@onready var player_state_machine: Node = $PlayerStateMachine

func _ready() -> void:
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)

func _on_died() -> void:
	queue_free()

func _on_damaged(amount: int) -> void:
	print("Took damage:", amount)

	player_state_machine.on_child_transition(
		player_state_machine.current_state,
		"hurt"
	)

func update_last_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = Vector2(sign(direction.x), 0)
		else:
			last_direction = Vector2(0, sign(direction.y))
