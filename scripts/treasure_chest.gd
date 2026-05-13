extends StaticBody2D

const CHEST_OPENING_SFX = preload("res://assets/Music&Sfx/sfx/chest_opening.mp3")

@onready var interactable: Area2D = $Interactable
@onready var treasure_chest_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var loot_table : LootTable

var chest_opening_sfx_player: AudioStreamPlayer


func _ready() -> void:
	chest_opening_sfx_player = AudioStreamPlayer.new()
	chest_opening_sfx_player.name = "ChestOpeningSfxPlayer"
	chest_opening_sfx_player.stream = CHEST_OPENING_SFX
	add_child(chest_opening_sfx_player)

	interactable.interact = _on_interact
	
func _on_interact():
	if treasure_chest_sprite.animation == "closed_chest":
		play_chest_opening_sfx()
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

func play_chest_opening_sfx() -> void:
	if chest_opening_sfx_player == null:
		return

	chest_opening_sfx_player.stop()
	chest_opening_sfx_player.play()
