extends State
class_name EnemyIdleState

@export var enemy: CharacterBody2D
@export var enemy_sprite: AnimatedSprite2D

@export var wait_time: float = 1.0

@onready var timer: Timer = Timer.new()


func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)


func enter() -> void:
	setup_references()

	if enemy == null:
		push_warning("EnemyIdle: enemy is null.")
		return

	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	play_idle_animation()

	timer.wait_time = wait_time
	timer.start()


func exit() -> void:
	timer.stop()


func physics_update(_delta: float) -> void:
	if enemy == null:
		setup_references()
		return

	if enemy.get("is_dead") == true:
		return

	if enemy.has_method("can_see_player") and enemy.can_see_player():
		Transitioned.emit(self, "chase")
		return


func _on_timer_timeout() -> void:
	Transitioned.emit(self, "wander")


func setup_references() -> void:
	if enemy == null:
		enemy = owner as CharacterBody2D

	if enemy_sprite == null and enemy != null:
		enemy_sprite = enemy.get_node_or_null("AnimatedSprite2D")


func play_idle_animation() -> void:
	if enemy_sprite == null:
		return

	var dir: Vector2 = enemy.get("last_direction")

	if abs(dir.x) > abs(dir.y):
		enemy_sprite.flip_h = dir.x < 0
		play_if_not_playing("idle_right")
	else:
		enemy_sprite.flip_h = false

		if dir.y < 0:
			play_if_not_playing("idle_up")
		else:
			play_if_not_playing("idle_down")


func play_if_not_playing(anim: String) -> void:
	if enemy_sprite == null:
		return

	if enemy_sprite.animation != anim:
		enemy_sprite.play(anim)
