extends Node
class_name Shop

var hovered_slot: Button = null

@onready var window : TextureRect = get_node("ShopWindow")
@onready var background_blur : TextureRect = get_node("BackgroundBlurTexture")

func _ready():
	toggle_window(false)
	
func _on_exit_button_pressed():
	toggle_window(false)
	
func toggle_window(open : bool):
	window.visible = open
	background_blur.visible = open
	
	if open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
