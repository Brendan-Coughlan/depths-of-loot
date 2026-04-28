extends Area2D


@export var item: ItemData
@export var amount: int = 1

@onready var inventory: Inventory = get_tree().get_nodes_in_group("player")[0].get_node("Inventory")
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
