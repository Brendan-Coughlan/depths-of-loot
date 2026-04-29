extends Node
class_name LevelManager

@export var map_generator: MapGenerator
@export var entry_scene: PackedScene
@export var exit_scene: PackedScene
@export var object_container: Node2D
@export var player: CharacterBody2D

@export var enemy_scene: PackedScene
@export var chest_scene: PackedScene
@export var enemy_count: int = 5
@export var chest_count: int = 3
@export var min_spawn_distance_from_entry: int = 6

@export var min_entry_exit_distance: int = 10
@export var player_z_index: int = 10
@export var enemy_z_index: int = 5
@export var chest_z_index: int = 4

var entry_cell: Vector2i = Vector2i.ZERO
var exit_cell: Vector2i = Vector2i.ZERO

func _ready() -> void:
	setup_level()

func setup_level() -> void:
	clear_objects()
	map_generator.generate_map()
	choose_entry_and_exit()
	spawn_entry()
	spawn_exit()
	place_player()
	spawn_random_objects()

func clear_objects() -> void:
	if object_container == null:
		push_error("LevelManager: object_container is not assigned.")
		return

	for child in object_container.get_children():
		child.queue_free()

func choose_entry_and_exit() -> void:
	var valid_cells: Array[Vector2i] = get_valid_2x2_cells()

	if valid_cells.is_empty():
		push_error("LevelManager: No valid 2x2 floor areas found for entry/exit.")
		return

	entry_cell = valid_cells.pick_random()

	var far_cells: Array[Vector2i] = []
	for cell in valid_cells:
		var distance := manhattan_distance(cell, entry_cell)
		if distance >= min_entry_exit_distance:
			far_cells.append(cell)

	if far_cells.is_empty():
		exit_cell = valid_cells.pick_random()
	else:
		exit_cell = far_cells.pick_random()

	print("Entry cell: ", entry_cell)
	print("Exit cell: ", exit_cell)

func get_valid_2x2_cells() -> Array[Vector2i]:
	var floor_cells: Array[Vector2i] = map_generator.get_floor_cells()
	var valid_cells: Array[Vector2i] = []

	for cell in floor_cells:
		if is_valid_2x2_floor(cell):
			valid_cells.append(cell)

	return valid_cells

func is_valid_2x2_floor(cell: Vector2i) -> bool:
	var floor_cells: Array[Vector2i] = map_generator.get_floor_cells()

	var needed_cells: Array[Vector2i] = [
		cell,
		cell + Vector2i(1, 0),
		cell + Vector2i(0, 1),
		cell + Vector2i(1, 1)
	]

	for c in needed_cells:
		if not floor_cells.has(c):
			return false

	return true

func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func spawn_entry() -> void:
	if entry_scene == null:
		push_warning("LevelManager: entry_scene is not assigned.")
		return

	var instance = entry_scene.instantiate()
	object_container.add_child(instance)
	instance.position = get_2x2_center(entry_cell)
	instance.z_index = chest_z_index

	print("Entry spawned at: ", instance.position)

func spawn_exit() -> void:
	if exit_scene == null:
		push_warning("LevelManager: exit_scene is not assigned.")
		return

	var instance = exit_scene.instantiate()
	object_container.add_child(instance)
	instance.position = get_2x2_center(exit_cell)
	instance.z_index = chest_z_index

	print("Exit spawned at: ", instance.position)

func place_player() -> void:
	player.position = get_tile_center(entry_cell)
	player.z_index = player_z_index
	print("Player spawned at: ", player.position)

func spawn_random_objects() -> void:
	var available_cells: Array[Vector2i] = map_generator.get_floor_cells().duplicate()

	available_cells.erase(entry_cell)
	available_cells.erase(exit_cell)

	available_cells = available_cells.filter(func(cell: Vector2i):
		return manhattan_distance(cell, entry_cell) >= min_spawn_distance_from_entry
	)

	available_cells.shuffle()

	for i in range(enemy_count):
		if available_cells.is_empty():
			return

		var cell: Vector2i = available_cells.pop_back() as Vector2i
		spawn_scene_at_cell(enemy_scene, cell, enemy_z_index)

	for i in range(chest_count):
		if available_cells.is_empty():
			return

		var cell: Vector2i = available_cells.pop_back() as Vector2i
		spawn_scene_at_cell(chest_scene, cell, chest_z_index)

func spawn_scene_at_cell(scene: PackedScene, cell: Vector2i, z_value: int) -> void:
	if scene == null:
		push_warning("LevelManager: spawn scene is not assigned.")
		return

	var instance = scene.instantiate()
	object_container.add_child(instance)

	instance.position = get_tile_center(cell)
	instance.z_index = z_value

	print("Spawned object at: ", cell)

func get_tile_center(cell: Vector2i) -> Vector2:
	var tilemap = map_generator.tilemap_layer
	var base_pos = tilemap.map_to_local(cell)
	var tile_size = tilemap.tile_set.tile_size
	return base_pos + Vector2(tile_size) / 2.0

func get_2x2_center(cell: Vector2i) -> Vector2:
	var tilemap = map_generator.tilemap_layer
	var base_pos = tilemap.map_to_local(cell)
	var tile_size = tilemap.tile_set.tile_size
	return base_pos + Vector2(tile_size)
