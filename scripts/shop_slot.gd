extends Control
class_name ShopSlot

var item : ItemData
var quantity : int
@onready var item_icon : TextureRect = get_node("Icon")
@onready var quantity_text : Label = get_node("Slot/QuantityText")

func set_item(new_item : ItemData):
	item = new_item
	quantity = 1
	
	if item == null:
		item_icon.visible = false
	else:
		item_icon.visible = true
		item_icon.texture = item.icon
  
	update_quantity_text()

func update_quantity_text():
	if quantity <= 1:
		quantity_text.text = ""
	else:
		quantity_text.text = str(quantity)


func _on_buy_button_pressed() -> void:
	print("Buy button pressed")
