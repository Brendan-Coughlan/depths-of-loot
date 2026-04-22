extends State
class_name EnemyWander

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var movement_speed: float = 5000.0
@export var move_time: float = 2.0

@onready var timer: Timer = Timer.new()

var direction : Vector2 = Vector2.ZERO
var possible_directions : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT] 

func _ready() -> void:
	add_child(timer)
	timer.wait_time = move_time
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

func enter() -> void:
	randomize_direction()
	play_run_animation()

func _on_timer_timeout():
	randomize_direction()

func randomize_direction():
	direction = possible_directions[randi() % possible_directions.size()]
	
func physics_update(_delta: float):
	if direction != Vector2.ZERO:
		enemy.velocity = direction * movement_speed * _delta
		
		if abs(direction.x) > abs(direction.y):
			enemy_sprite.flip_h = direction.x < 0
			enemy_sprite.play("run_right")
		else:
			enemy_sprite.play("run_up" if direction.y < 0 else "run_down")
		
		enemy.move_and_slide()

func play_run_animation() -> void:
	var dir := enemy.last_direction

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")

func play_if_not_playing(anim: String) -> void:
	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
