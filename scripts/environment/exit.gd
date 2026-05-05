extends Node2D
class_name DungeonExit

@export var interact_label: Label

var player_inside: bool = false
var can_use_exit: bool = false
var level_manager: Node = null

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("level_manager")

	if interact_label != null:
		interact_label.hide()

	var area := $Area2D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	can_use_exit = are_all_enemies_cleared()

	if player_inside and can_use_exit:
		if interact_label != null:
			interact_label.text = "Press E to go to next floor"
			interact_label.show()

		if Input.is_action_just_pressed("interact"):
			go_to_next_floor()
	elif player_inside and not can_use_exit:
		if interact_label != null:
			interact_label.text = "Clear all enemies first"
			interact_label.show()
	else:
		if interact_label != null:
			interact_label.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if interact_label != null:
			interact_label.hide()

func are_all_enemies_cleared() -> bool:
	return get_tree().get_nodes_in_group("enemies").is_empty()

func go_to_next_floor() -> void:
	if level_manager != null and level_manager.has_method("next_floor"):
		level_manager.next_floor()
	else:
		push_warning("DungeonExit: Cannot find LevelManager or next_floor().")
