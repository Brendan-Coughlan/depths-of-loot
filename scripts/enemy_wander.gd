extends State
class_name EnemyWander

@onready var enemy: CharacterBody2D = $"../.."
@onready var timer: Timer = $"../../Timer"

var direction : Vector2 = Vector2.ZERO
var possible_directions : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT] 
@export var movement_speed : int = 2000
@export var enemy_sprite : AnimatedSprite2D

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func randomize_direction():
	direction = possible_directions[randi() % possible_directions.size()]

func enter():
	randomize_direction()
	
func _on_timer_timeout():
	randomize_direction()
	
func physics_update(_delta: float):
	if direction != Vector2.ZERO:
		enemy.velocity = direction * movement_speed * _delta
		
		if abs(direction.x) > abs(direction.y):
			enemy_sprite.flip_h = direction.x < 0
			enemy_sprite.play("run_right")
		else:
			enemy_sprite.play("run_up" if direction.y < 0 else "run_down")
		
		enemy.move_and_slide()
