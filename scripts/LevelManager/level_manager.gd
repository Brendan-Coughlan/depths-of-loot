extends Node
class_name LevelManager

@export var map_generator: MapGenerator
@export var entities_node: Node2D
@export var player_scene: PackedScene

var player_instance: CharacterBody2D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	setup_level()

func setup_level() -> void:
	clear_entities()

	var floors: Array[Vector2i] = map_generator.generate_map()

	if floors.is_empty():
		push_error("No floor cells generated. Cannot spawn player.")
		return

	var player_cell: Vector2i = floors.pick_random()
	spawn_player(player_cell)

func spawn_player(cell: Vector2i) -> void:
	if player_scene == null:
		push_error("Player scene is not assigned in LevelManager.")
		return

	player_instance = player_scene.instantiate()
	entities_node.add_child(player_instance)

	var world_position: Vector2 = map_generator.tilemap_layer.map_to_local(cell)
	player_instance.global_position = map_generator.tilemap_layer.to_global(world_position)

func clear_entities() -> void:
	for child in entities_node.get_children():
		child.queue_free()
