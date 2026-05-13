extends Control
class_name ShopSlot

const PURCHASE_SFX = preload("res://assets/Music&Sfx/sfx/purchase.mp3")

var item : ItemData
var quantity : int
@onready var item_icon : TextureRect = get_node("Icon")
@onready var quantity_text : Label = get_node("QuantityText")
@onready var value_text : Label = get_node("ValueText")

func set_item(new_item : ItemData):
	item = new_item
	quantity = 1
	
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
		
	var player_inventory: Inventory = get_tree().get_first_node_in_group("player").get_node("Inventory")
	if player_inventory == null:
		return
	
	if player_inventory.gold >= item.value:
		player_inventory.gold -= item.value
		player_inventory.add_item(item)
		play_purchase_sfx()

func _on_sell_button_pressed() -> void:
	if item == null:
		return
		
	var player_inventory: Inventory = get_tree().get_first_node_in_group("player").get_node("Inventory")
	if player_inventory == null:
		return
		
	if player_inventory.get_number_of_item(item) > 0:
		player_inventory.gold += item.value
		player_inventory.remove_item(item)

func play_purchase_sfx() -> void:
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = PURCHASE_SFX
	sfx_player.finished.connect(sfx_player.queue_free)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
