extends Area2D

const ITEM_PICKUP_SFX = preload("res://assets/Music&Sfx/sfx/item_pickup.mp3")

@export var item: ItemData
@export var amount: int = 1

@export var gold_item: ItemData

@onready var inventory: Inventory = get_tree().get_nodes_in_group("player")[0].get_node("Inventory")
@onready var interactable: Area2D = $Interactable
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if item and item.icon:
		sprite.texture = item.icon
		
	interactable.interact = _on_interact

func _on_interact():
	interactable.is_interactable = false
	if item == gold_item:
		inventory.add_gold(10)
	else:
		inventory.add_item(item)
	play_item_pickup_sfx()
	queue_free()

func play_item_pickup_sfx() -> void:
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = ITEM_PICKUP_SFX
	sfx_player.finished.connect(sfx_player.queue_free)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
