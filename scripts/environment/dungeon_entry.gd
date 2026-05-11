extends StaticBody2D
class_name DungeonEntry

@onready var interactable: Area2D = $Interactable

@export var target_scene_path: String = "res://scenes/game.tscn"

var go_next_floor_mode: bool = false


func _ready() -> void:
	interactable.interact = _on_interact

	if go_next_floor_mode:
		interactable.interact_name = "Go to next floor"
	else:
		interactable.interact_name = "Enter"


func set_as_next_floor_exit() -> void:
	go_next_floor_mode = true

	if interactable != null:
		interactable.interact_name = "Go to next floor"
		interactable.interact = _on_interact


func _on_interact() -> void:
	if go_next_floor_mode:
		var level_manager := get_tree().get_first_node_in_group("level_manager")

		if level_manager != null and level_manager.has_method("next_floor"):
			level_manager.next_floor()
		else:
			push_warning("DungeonEntry: Cannot find LevelManager or next_floor().")
	else:
		get_tree().root.get_node("Main").load_scene(target_scene_path)
