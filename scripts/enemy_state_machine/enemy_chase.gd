extends State
class_name EnemyChase

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D
@export var target: Node2D
@export var movement_speed: float = 5000.0

func enter() -> void:
	target = get_tree().get_first_node_in_group("player")
	play_run_animation()

func physics_update(_delta: float):
	if target == null:
		return
		
	var direction = (target.global_position - enemy.global_position).normalized()
	
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
