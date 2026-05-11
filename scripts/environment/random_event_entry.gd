extends Node2D
class_name RandomEventEntry

@onready var level_manager: Node = get_tree().get_first_node_in_group("level_manager")
@onready var interactable: Area2D = $Interactable

enum EntryMode {
	TO_RANDOM_EVENT,
	TO_NEXT_FLOOR
}

@export var mode: EntryMode = EntryMode.TO_RANDOM_EVENT


func _ready() -> void:
	interactable.interact = _on_interact
	interactable.is_interactable = true


func _process(_delta: float) -> void:
	match mode:
		EntryMode.TO_RANDOM_EVENT:
			interactable.interact_name = "Enter random event"

		EntryMode.TO_NEXT_FLOOR:
			interactable.interact_name = "Go to next floor"


func _on_interact() -> void:
	if level_manager == null:
		level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager == null:
		push_warning("RandomEventEntry: Cannot find LevelManager.")
		return

	match mode:
		EntryMode.TO_RANDOM_EVENT:
			if level_manager.has_method("enter_random_event_room"):
				level_manager.enter_random_event_room()
			else:
				push_warning("RandomEventEntry: LevelManager has no enter_random_event_room().")

		EntryMode.TO_NEXT_FLOOR:
			if level_manager.has_method("leave_random_event_and_go_next_floor"):
				level_manager.leave_random_event_and_go_next_floor()
			elif level_manager.has_method("next_floor"):
				level_manager.next_floor()
			else:
				push_warning("RandomEventEntry: LevelManager has no next floor function.")
