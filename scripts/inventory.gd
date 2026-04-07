extends Node
class_name Inventory

var slots : Array[InventorySlot]
var hotbar : Array[InventorySlot]
@onready var window : Panel = get_node("InventoryWindow")
@onready var info_text : Label = get_node("InventoryWindow/InfoText")
