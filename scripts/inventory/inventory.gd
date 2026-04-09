extends Node
class_name Inventory

var slots : Array[InventorySlot]
var hotbar : Array[InventorySlot]
var hovered_slot: Button = null

@onready var window : Panel = get_node("InventoryWindow")
@onready var info_text : Label = get_node("InventoryWindow/InfoText")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_window(!window.visible)

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

	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func add_item(item : ItemData):
	var slot = get_slot_to_add(item)
	
	if slot == null:
		return
		
	if slot.item == null:
		slot.set_item(item)
	elif slot.item == item:
		slot.add_item()

func remove_item(item : ItemData):
	var slot = get_slot_to_remove(item)
  
	if slot == null or slot.item == item:
		return
	
	slot.remove_item()

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
