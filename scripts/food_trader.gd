extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var trader_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shop_menu: Shop = $Shop

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	shop_menu.toggle_window(true)
	trader_sprite.play("wave")
	await trader_sprite.animation_finished
	trader_sprite.play("idle")
