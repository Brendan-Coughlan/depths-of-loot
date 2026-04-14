extends Area2D
class_name HurtArea2D

func _ready() -> void:
	area_entered.connect(
		func _on_area_entered(hit_area: Area2D) -> void:
			if hit_area != null and owner.has_method("take_damage"):
				owner.take_damage()
	)
