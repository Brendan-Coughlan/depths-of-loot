extends Node
class_name InventorySlot

var item : ItemData
var quantity : int
@onready var icon : TextureRect = get_node("Icon")
@onready var quantity_text : Label = get_node("QuantityText")
var inventory : Inventory
