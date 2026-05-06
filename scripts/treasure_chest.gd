extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var treasure_chest_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var dropped_item : ItemData

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if treasure_chest_sprite.animation == "closed_chest":
		treasure_chest_sprite.play("opened_chest")
		interactable.is_interactable = false
		spawn_item(dropped_item, 1)
		
func spawn_item(item: ItemData, amount: int):
	if item == null:
		push_warning("TreasureChest: dropped_item is null.")
		return

	var instance = preload("res://scenes/item_pickup.tscn").instantiate()
	instance.item = item
	instance.amount = amount

	var world := get_tree().get_first_node_in_group("world")

	if world == null:
		world = get_parent()

	if world == null:
		push_warning("TreasureChest: Cannot find world or parent to spawn item.")
		return

	world.add_child(instance)
	instance.global_position = global_position + Vector2(0, 5)
