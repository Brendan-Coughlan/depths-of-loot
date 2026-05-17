extends Node
class_name Inventory

signal inventory_changed

@export var gold: int = 25

var slots : Array[InventorySlot]
var hovered_slot: TextureButton = null

@onready var window : TextureRect = get_node("InventoryWindow")
@onready var info_text : Label = get_node("InventoryWindow/InfoText")
@onready var background_blur : TextureRect = get_node("BackgroundBlurTexture")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_window(!window.visible)
	elif event.is_action_pressed("interact") and hovered_slot:
		get_parent().use_item(hovered_slot.item)

func _on_exit_button_pressed():
	toggle_window(false)

func _ready():
	toggle_window(false)
	update_info_text()

	for child in get_node("InventoryWindow/SlotContainer").get_children():
		slots.append(child)
		child.set_item(null)
		child.inventory = self
		child.slot_hovered.connect(_on_slot_hovered)

func _on_slot_hovered(slot):
	hovered_slot = slot
	update_info_text()

func toggle_window(open : bool):
	window.visible = open
	background_blur.visible = open

	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func add_item(item : ItemData) -> bool:
	if item == null:
		return false

	var slot = get_slot_to_add(item)

	if slot == null:
		return false

	if slot.item == null:
		slot.set_item(item)
	elif slot.item == item:
		slot.add_item()

	if get_parent().has_method("recalculate_stats"):
		get_parent().recalculate_stats()

	inventory_changed.emit()
	return true

func remove_item(item : ItemData) -> bool:
	if item == null:
		return false

	var slot = get_slot_to_remove(item)

	if slot == null or slot.item != item:
		return false

	slot.remove_item()

	if get_parent().has_method("recalculate_stats"):
		get_parent().recalculate_stats()

	inventory_changed.emit()
	return true

func get_slot_to_add(item : ItemData) -> InventorySlot:
	for slot in slots:
		if slot.item == item and slot.quantity < item.max_stack_size:
			return slot

	for slot in slots:
		if slot.item == null:
			return slot

	return null

func get_slot_to_remove(item : ItemData) -> InventorySlot:
	for slot in slots:
		if slot.item == item:
			return slot

	return null

func get_number_of_item(item : ItemData) -> int:
	var total = 0

	for slot in slots:
		if slot.item == item:
			total += slot.quantity

	return total

func update_info_text():
	if hovered_slot and hovered_slot.item:
		info_text.text = hovered_slot.item.name
	else:
		info_text.text = ""

func add_gold(amount: int):
	gold += amount
	inventory_changed.emit()
