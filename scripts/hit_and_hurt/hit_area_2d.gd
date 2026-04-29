class_name HitArea2D
extends Area2D

signal hit(hurtArea2D)

func _init() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurtArea2D: HurtArea2D) -> void:
	print("[Hit] %s => %s" % [owner.name, hurtArea2D.owner.name])
	hit.emit(hurtArea2D)
	hurtArea2D.hurt.emit(self)
