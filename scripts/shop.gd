extends Node
class_name Shop

var hovered_slot: Button = null

@onready var window: TextureRect = get_node("ShopWindow")
@onready var background_blur: TextureRect = get_node("BackgroundBlurTexture")
@onready var buy_slots_container: GridContainer = get_node("ShopWindow/BuySlotContainer")
@onready var sell_slots_container: GridContainer = get_node("ShopWindow/SellSlotContainer")

@export var buy_window_texture: AtlasTexture
@export var sell_window_texture: AtlasTexture

@export var buy_shop_items: Array[ItemData]
@export var sell_shop_items: Array[ItemData]
var shop_slot_scene = preload("res://scenes/shop_slot.tscn")
var player_inventory: Inventory
var sell_refresh_queued := false

func _ready():
	toggle_window(false)
	player_inventory = get_player_inventory()
	if player_inventory != null:
		player_inventory.inventory_changed.connect(_on_player_inventory_changed)
	populate_shop()

func populate_shop():
	clear_container(buy_slots_container)
	clear_container(sell_slots_container)

	for item in buy_shop_items:
		var slot: ShopSlot = shop_slot_scene.instantiate()

		var buy_button: TextureButton = slot.get_node("BuyButton")
		var sell_button: TextureButton = slot.get_node("SellButton")
		buy_button.visible = true
		buy_button.disabled = false
		sell_button.visible = false
		sell_button.disabled = true
		buy_slots_container.add_child(slot)
		slot.transaction_completed.connect(_on_slot_transaction_completed)

		slot.set_item(item)

	populate_sell_slots()

	buy_slots_container.visible = true
	sell_slots_container.visible = false

func populate_sell_slots() -> void:
	sell_refresh_queued = false
	clear_container(sell_slots_container)

	var sell_item_counts := get_sell_item_counts()
	for item in get_ordered_sell_items(sell_item_counts):
		var slot: ShopSlot = shop_slot_scene.instantiate()

		var buy_button: TextureButton = slot.get_node("BuyButton")
		var sell_button: TextureButton = slot.get_node("SellButton")
		buy_button.visible = false
		buy_button.disabled = true
		sell_button.visible = true
		sell_button.disabled = false
		sell_slots_container.add_child(slot)
		slot.transaction_completed.connect(_on_slot_transaction_completed)

		slot.set_item(item, sell_item_counts[item])

func get_sell_item_counts() -> Dictionary:
	var sell_item_counts := {}
	player_inventory = get_player_inventory()
	if player_inventory == null:
		return sell_item_counts

	for inventory_slot in player_inventory.slots:
		if inventory_slot.item == null or inventory_slot.quantity <= 0:
			continue
		if inventory_slot.item.value <= 0:
			continue

		sell_item_counts[inventory_slot.item] = int(sell_item_counts.get(inventory_slot.item, 0)) + inventory_slot.quantity

	return sell_item_counts

func get_ordered_sell_items(sell_item_counts: Dictionary) -> Array[ItemData]:
	var ordered_items: Array[ItemData] = []

	for item in sell_shop_items:
		if sell_item_counts.has(item):
			ordered_items.append(item)

	for item in sell_item_counts.keys():
		if not ordered_items.has(item):
			ordered_items.append(item)

	return ordered_items


func _on_exit_button_pressed():
	toggle_window(false)

func toggle_window(open : bool):
	window.visible = open
	background_blur.visible = open

	if open:
		connect_player_inventory()
		populate_sell_slots()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_buy_window_button_pressed() -> void:
	window.texture = buy_window_texture
	buy_slots_container.visible = true
	sell_slots_container.visible = false

func _on_sell_window_button_pressed() -> void:
	window.texture = sell_window_texture
	buy_slots_container.visible = false
	sell_slots_container.visible = true

func _on_slot_transaction_completed() -> void:
	queue_sell_refresh()

func _on_player_inventory_changed() -> void:
	if sell_slots_container.visible:
		queue_sell_refresh()

func queue_sell_refresh() -> void:
	if sell_refresh_queued:
		return

	sell_refresh_queued = true
	call_deferred("populate_sell_slots")

func clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func connect_player_inventory() -> void:
	player_inventory = get_player_inventory()
	if player_inventory == null:
		return

	if not player_inventory.inventory_changed.is_connected(_on_player_inventory_changed):
		player_inventory.inventory_changed.connect(_on_player_inventory_changed)

func get_player_inventory() -> Inventory:
	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Inventory"):
		return null

	return player.get_node("Inventory") as Inventory
