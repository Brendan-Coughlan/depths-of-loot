extends Area2D
class_name HitArea2D

@export var damage: int = 10

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtArea2D:
		var hurt_area := area as HurtArea2D
		hurt_area.hurt(damage)
