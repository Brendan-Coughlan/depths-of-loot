extends CharacterBody2D
class_name Player

var last_direction: Vector2 = Vector2.DOWN

@onready var health: HealthComponent = $HealthComponent
@onready var player_state_machine: Node = $PlayerStateMachine
@onready var inventory: Inventory = $Inventory

@export var base_movement_speed: float = 5000.0
var movement_speed: float = 5000.0

func _ready() -> void:
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	recalculate_stats()

func _on_died() -> void:
	#queue_free()
	
	player_state_machine.on_child_transition(
		player_state_machine.current_state,
		"death"
	)

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

func recalculate_stats():
	movement_speed = base_movement_speed

	var health_gem_item = preload("res://resources/items/health_gem.tres")
	var speed_gem_item = preload("res://resources/items/speed_gem.tres")

	var health_gem_amount = inventory.get_number_of_item(health_gem_item)
	var speed_gem_amount = inventory.get_number_of_item(speed_gem_item)

	movement_speed += speed_gem_amount * 500.0
	
	health.max_health += health_gem_amount * 25
	health.set_health(health.current_health + health_gem_amount * 25)
