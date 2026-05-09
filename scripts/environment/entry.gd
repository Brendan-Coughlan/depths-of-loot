extends Node2D
class_name Entry

@onready var level_manager: Node = get_tree().get_first_node_in_group("level_manager")
@export var target_scene_path: String = "res://scenes/market.tscn"

func return_to_surface() -> void:
	get_tree().root.get_node("Main").load_scene(target_scene_path)
		
@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	return_to_surface()
