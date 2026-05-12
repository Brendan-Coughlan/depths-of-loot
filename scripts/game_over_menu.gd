extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
