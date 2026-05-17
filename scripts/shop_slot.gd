extends Control
class_name ShopSlot

const PURCHASE_SFX = preload("res://assets/Music&Sfx/sfx/purchase.mp3")

signal transaction_completed

var item : ItemData
var quantity : int
@onready var item_icon : TextureRect = get_node("Icon")
@onready var quantity_text : Label = get_node("QuantityText")
@onready var value_text : Label = get_node("ValueText")

func set_item(new_item : ItemData, new_quantity: int = 1):
	item = new_item
	quantity = max(new_quantity, 1)

	if item == null:
		item_icon.visible = false
	else:
		item_icon.visible = true
		item_icon.texture = item.icon

	update_quantity_text()
	update_value_text()

func update_quantity_text():
	if quantity <= 1:
		quantity_text.text = ""
	else:
		quantity_text.text = str(quantity)

func update_value_text():
	if item == null:
		return

	value_text.text = "$" + str(item.value)

func _on_buy_button_pressed() -> void:
	if item == null:
		return

	var player_inventory: Inventory = get_player_inventory()
	if player_inventory == null:
		return

	if player_inventory.gold >= item.value:
		if player_inventory.add_item(item):
			player_inventory.add_gold(-item.value)
			play_purchase_sfx()
			transaction_completed.emit()

func _on_sell_button_pressed() -> void:
	if item == null:
		return

	var player_inventory: Inventory = get_player_inventory()
	if player_inventory == null:
		return

	if player_inventory.remove_item(item):
		player_inventory.add_gold(item.value)
		play_purchase_sfx()
		transaction_completed.emit()

func get_player_inventory() -> Inventory:
	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Inventory"):
		return null

	return player.get_node("Inventory") as Inventory

func play_purchase_sfx() -> void:
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = PURCHASE_SFX
	sfx_player.finished.connect(sfx_player.queue_free)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
