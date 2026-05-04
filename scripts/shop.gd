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

func _ready():
	toggle_window(false)
	populate_shop()
	
func populate_shop():
	for child in buy_slots_container.get_children():
		child.queue_free()
		
	for child in sell_slots_container.get_children():
		child.queue_free()
	
	for item in buy_shop_items:
		var slot: ShopSlot = shop_slot_scene.instantiate()
		
		var buy_button: TextureButton = slot.get_node("BuyButton")
		var sell_button: TextureButton = slot.get_node("SellButton")
		buy_button.visible = true
		buy_button.disabled = false
		sell_button.visible = false
		sell_button.disabled = true
		buy_slots_container.add_child(slot)
		
		slot.set_item(item)
		
	for item in sell_shop_items:
		var slot = shop_slot_scene.instantiate()
		
		var buy_button: TextureButton = slot.get_node("BuyButton")
		var sell_button: TextureButton = slot.get_node("SellButton")
		buy_button.visible = false
		buy_button.disabled = true
		sell_button.visible = true
		sell_button.disabled = false
		sell_slots_container.add_child(slot)
		
		slot.set_item(item)
		
	buy_slots_container.visible = true
	sell_slots_container.visible = false
	
	
func _on_exit_button_pressed():
	toggle_window(false)
	
func toggle_window(open : bool):
	window.visible = open
	background_blur.visible = open
	
	if open:
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
