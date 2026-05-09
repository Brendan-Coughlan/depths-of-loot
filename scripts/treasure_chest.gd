extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var treasure_chest_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var loot_table : LootTable

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	if treasure_chest_sprite.animation == "closed_chest":
		treasure_chest_sprite.play("opened_chest")
		interactable.is_interactable = false
		drop_loot()

func drop_loot():
	var loot = LootManager.roll_loot(loot_table)

	for entry in loot:
		spawn_item(entry.item, entry.amount)

func spawn_item(item: ItemData, amount: int):
	for i in range(amount):
		var instance = preload("res://scenes/item_pickup.tscn").instantiate()
		instance.item = item
		instance.amount = amount

		var world = get_tree().get_first_node_in_group("world")
		world.add_child(instance)

		instance.global_position = global_position + Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)
