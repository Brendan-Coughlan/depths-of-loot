extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@export var target_scene_path: String = "res://scenes/game.tscn"

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	get_tree().root.get_node("Main").load_scene(target_scene_path)
