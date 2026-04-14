extends State
class_name EnemyDeath

@export var enemy: Enemy
@export var enemy_sprite: AnimatedSprite2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	
	if enemy_sprite:
		enemy_sprite.play("death")
		if not enemy_sprite.animation_finished.is_connected(_on_animation_finished):
			enemy_sprite.animation_finished.connect(_on_animation_finished)
	else:
		print("Enemy sprite not found")

func exit() -> void:
	if enemy_sprite and enemy_sprite.animation_finished.is_connected(_on_animation_finished):
		enemy_sprite.animation_finished.disconnect(_on_animation_finished)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO

func _input(_event: InputEvent) -> void:
	pass

func _on_animation_finished() -> void:
	if enemy_sprite.animation == "death":
		print("Enemy is dead")
		enemy.queue_free()
