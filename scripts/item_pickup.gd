extends Area2D


@export var item: ItemData
@export var amount: int = 1

@onready var inventory: Inventory = $"../Player/Inventory"
@onready var interactable: Area2D = $Interactable
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if item and item.icon:
		sprite.texture = item.icon
		
	interactable.interact = _on_interact

func _on_interact():
	interactable.is_interactable = false
	inventory.add_item(item)
	queue_free()
