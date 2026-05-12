extends Control

@export var minimap_camera: Camera2D
@export var player_dot_radius: float = 4.0
@export var exit_dot_radius: float = 4.0


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var exit := get_tree().get_first_node_in_group("normal_floor_exit") as Node2D

	if player == null or minimap_camera == null:
		return

	var center := size * 0.5
	draw_circle(center, player_dot_radius, Color(1.0, 0.0, 0.0))

	if exit != null:
		var exit_offset := (exit.global_position - player.global_position) * minimap_camera.zoom
		draw_circle(center + exit_offset, exit_dot_radius, Color(0.0, 0.35, 1.0))
