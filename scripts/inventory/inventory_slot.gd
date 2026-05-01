extends TextureButton
class_name InventorySlot

var item : ItemData
var quantity : int
@onready var item_icon : TextureRect = get_node("Icon")
@onready var quantity_text : Label = get_node("QuantityText")
var inventory : Inventory

signal slot_hovered(slot)

func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	emit_signal("slot_hovered", self)

func set_item(new_item : ItemData):
	item = new_item
	quantity = 1
	
	if item == null:
		item_icon.visible = false
	else:
		item_icon.visible = true
		item_icon.texture = item.icon
  
	update_quantity_text()

func add_item():
	quantity += 1
	update_quantity_text()

func remove_item():
	quantity -= 1
	update_quantity_text()
	
	if quantity == 0:
		set_item(null)

func update_quantity_text():
	if quantity <= 1:
		quantity_text.text = ""
	else:
		quantity_text.text = str(quantity)
