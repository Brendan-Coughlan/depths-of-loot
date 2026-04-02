extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var treasure_chest_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if treasure_chest_sprite.animation == "closed_chest":
		treasure_chest_sprite.play("opened_chest")
		interactable.is_interactable = false
		print("Opened chest")
