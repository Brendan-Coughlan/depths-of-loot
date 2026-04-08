extends State
class_name PlayerDeath

@onready var player: CharacterBody2D = $"../.."
@export var player_sprite: AnimatedSprite2D

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player_sprite:
		player_sprite.play("death")
		if not player_sprite.animation_finished.is_connected(_on_animation_finished):
			player_sprite.animation_finished.connect(_on_animation_finished)
	else:
		print("Player sprite not found")

func exit() -> void:
	if player_sprite and player_sprite.animation_finished.is_connected(_on_animation_finished):
		player_sprite.animation_finished.disconnect(_on_animation_finished)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO

func _input(_event: InputEvent) -> void:
	pass

func _on_animation_finished() -> void:
	if player_sprite.animation == "death":
		print("Player is dead")
		# queue_free()
		# get_tree().reload_current_scene()
		# Transitioned.emit(self, "game_over")
