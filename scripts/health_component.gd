extends Node
class_name HealthComponent

signal health_changed(current, max)
signal damaged(amount)
signal healed(amount)
signal died

@export var max_health: int = 100
@export var current_health: int = 100
@export var invulnerable: bool = false

func _ready():
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int) -> void:
	if invulnerable:
		return
		
	if amount <= 0:
		return
		
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)

	emit_signal("damaged", amount)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if amount <= 0:
		return
		
	current_health += amount
	current_health = min(current_health, max_health)

	emit_signal("healed", amount)
	emit_signal("health_changed", current_health, max_health)

func set_health(value: int) -> void:
	current_health = clamp(value, 0, max_health)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		die()

func die() -> void:
	emit_signal("died")
