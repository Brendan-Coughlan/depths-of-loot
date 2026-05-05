extends State
class_name EnemyWanderState

@export var enemy: CharacterBody2D
@export var enemy_sprite: AnimatedSprite2D

@export var move_time: float = 2.0

@onready var timer: Timer = Timer.new()

var direction: Vector2 = Vector2.ZERO

var possible_directions: Array[Vector2] = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]


func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)


func enter() -> void:
	setup_references()

	if enemy == null:
		push_warning("EnemyWander: enemy is null.")
		return

	randomize_direction()
	timer.wait_time = move_time
	timer.start()


func exit() -> void:
	timer.stop()

	if enemy != null:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()


func physics_update(_delta: float) -> void:
	if enemy == null:
		setup_references()
		return

	if enemy.get("is_dead") == true:
		return

	if enemy.has_method("can_see_player") and enemy.can_see_player():
		Transitioned.emit(self, "chase")
		return

	enemy.velocity = direction * enemy.get("movement_speed")
	enemy.move_and_slide()

	if direction != Vector2.ZERO:
		if enemy.has_method("update_last_direction"):
			enemy.update_last_direction(direction)

		play_run_animation(direction)

	if enemy.get_slide_collision_count() > 0:
		Transitioned.emit(self, "idle")


func _on_timer_timeout() -> void:
	Transitioned.emit(self, "idle")


func randomize_direction() -> void:
	direction = possible_directions.pick_random()


func setup_references() -> void:
	if enemy == null:
		enemy = owner as CharacterBody2D

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")


func play_run_animation(dir: Vector2) -> void:
	if enemy_sprite == null:
		return

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("run_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			play_if_not_playing("run_up")
		else:
			play_if_not_playing("run_down")


func play_if_not_playing(anim: String) -> void:
	if enemy_sprite == null:
		return

	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
