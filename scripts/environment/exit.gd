extends Node2D
class_name Exit

@onready var level_manager: Node = get_tree().get_first_node_in_group("level_manager")

func are_all_enemies_cleared() -> bool:
	return get_tree().get_nodes_in_group("enemies").is_empty()

func go_to_next_floor() -> void:
	if level_manager != null and level_manager.has_method("next_floor"):
		level_manager.next_floor()
	else:
		push_warning("DungeonExit: Cannot find LevelManager or next_floor().")
		
@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact

func _process(_delta: float) -> void:
	var can_use_exit: bool = are_all_enemies_cleared()

	if can_use_exit:
		interactable.interact_name = "Go to next floor"
	else:
		interactable.interact_name = "Clear all enemies first"

func _on_interact():
	var can_use_exit: bool = are_all_enemies_cleared()
	
	if can_use_exit:
		go_to_next_floor()
