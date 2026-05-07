extends Area2D
class_name InteractableArea

@export var is_interactable: bool = true
@export var interact_name: String = "Enter"
@export var target_scene_path: String = "res://scenes/game.tscn"


func interact() -> void:
	if not is_interactable:
		return

	get_tree().root.get_node("Main").load_scene(target_scene_path)
