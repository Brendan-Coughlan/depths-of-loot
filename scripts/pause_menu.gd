extends CanvasLayer

var paused: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if paused:
			resume_game()
		else:
			pause_game()

func _ready() -> void:
	resume_game()

func _on_resume_pressed() -> void:
	resume_game()
	
func _on_exit_button_pressed():
	resume_game()

func _on_settings_pressed() -> void:
	print("Options pressed")

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func pause_game():
	get_tree().paused = true
	paused = true
	self.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func resume_game():
	get_tree().paused = false
	paused = false
	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
