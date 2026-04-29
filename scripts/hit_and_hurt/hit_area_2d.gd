extends Area2D
class_name HitArea2D

@export var damage: int = 10

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	#print("HitArea detected:", area.name)
	#print("Script:", area.get_script())
#
	#if area is HurtArea2D:
		#print("YES, this is HurtArea2D")
		#(area as HurtArea2D).hurt(damage)
	#else:
		#print("NO, this is only Area2D")
	
	if area is HurtArea2D:
		var hurt_area := area as HurtArea2D
		hurt_area.hurt(damage)
