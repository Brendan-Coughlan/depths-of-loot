extends CharacterBody2D
class_name Player

var last_direction: Vector2 = Vector2.DOWN
@onready var health: HealthComponent = $HealthComponent

func _ready():
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	
func _on_died():
	queue_free()

func _on_damaged(amount):
	print("Took damage:", amount)

func update_last_direction(direction: Vector2):
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = Vector2(sign(direction.x), 0)
		else:
			last_direction = Vector2(0, sign(direction.y))
