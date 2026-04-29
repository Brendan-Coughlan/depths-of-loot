extends Area2D
class_name HurtArea2D

@export var health_component: HealthComponent

func hurt(amount: int) -> void:
	if health_component == null:
		push_warning("HurtArea2D has no HealthComponent assigned.")
		return

	health_component.take_damage(amount)
