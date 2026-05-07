extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed() -> void:
	print("Options pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
