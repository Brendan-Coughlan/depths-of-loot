extends Node2D
class_name InteractingComponent

@onready var interact_label: Label = $InteractLabel

var current_interactions: Array[Area2D] = []
var can_interact: bool = true


func _ready() -> void:
	interact_label.hide()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not can_interact:
		return

	var interactable := get_nearest_interactable()

	if interactable == null:
		return

	can_interact = false
	interact_label.hide()

	await interactable.interact.call()

	can_interact = true


func _process(_delta: float) -> void:
	var interactable := get_nearest_interactable()

	if interactable != null and can_interact:
		interact_label.text = interactable.interact_name
		interact_label.show()
	else:
		interact_label.hide()


func get_nearest_interactable() -> Area2D:
	clean_invalid_interactions()

	if current_interactions.is_empty():
		return null

	current_interactions.sort_custom(_sort_by_nearest)

	for area in current_interactions:
		if not is_instance_valid(area):
			continue

		if not _is_valid_interactable(area):
			continue

		if area.is_interactable:
			return area

	return null


func clean_invalid_interactions() -> void:
	for i in range(current_interactions.size() - 1, -1, -1):
		var area := current_interactions[i]

		if not is_instance_valid(area):
			current_interactions.remove_at(i)
			continue

		if not _is_valid_interactable(area):
			current_interactions.remove_at(i)


func _is_valid_interactable(area: Area2D) -> bool:
	if area == null:
		return false

	if not ("is_interactable" in area):
		return false

	if not ("interact_name" in area):
		return false

	if not ("interact" in area):
		return false

	return true


func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area_1_dist := global_position.distance_to(area1.global_position)
	var area_2_dist := global_position.distance_to(area2.global_position)

	return area_1_dist < area_2_dist


func _on_interact_range_area_entered(area: Area2D) -> void:
	if not _is_valid_interactable(area):
		return

	if current_interactions.has(area):
		return

	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)
