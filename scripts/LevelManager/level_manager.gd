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
	if map_generator == null:
		push_error("LevelManager: map_generator is not assigned.")
		return

	if object_container == null:
		push_error("LevelManager: object_container is not assigned.")
		return

	if player == null:
		push_error("LevelManager: player is not assigned.")
		return

	clear_objects()
	map_generator.generate_map()
	choose_entry_and_exit()
	spawn_entry()
	spawn_exit()
	place_player()
	spawn_random_objects()


func clear_objects() -> void:
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
	if player == null:
		push_error("LevelManager: player is not assigned.")
		return

	if not is_valid_2x2_floor(entry_cell):
		push_error("LevelManager: entry_cell is not a valid 2x2 floor area.")
		return

	player.position = get_tile_center(entry_cell)
	player.z_index = player_z_index

	if not player.is_in_group("player"):
		player.add_to_group("player")

	print("Player spawned at: ", player.position)


func spawn_random_objects() -> void:
	var available_cells: Array[Vector2i] = map_generator.get_floor_cells().duplicate()

	remove_2x2_area_from_cells(available_cells, entry_cell)
	remove_2x2_area_from_cells(available_cells, exit_cell)

	available_cells = available_cells.filter(func(cell: Vector2i):
		return manhattan_distance(cell, entry_cell) >= min_spawn_distance_from_entry
	)

	available_cells.shuffle()

	for i in range(enemy_count):
		if available_cells.is_empty():
			return

		var cell: Vector2i = available_cells.pop_back()
		spawn_scene_at_cell(enemy_scene, cell, enemy_z_index)

	for i in range(chest_count):
		if available_cells.is_empty():
			return

		var cell: Vector2i = available_cells.pop_back()
		spawn_scene_at_cell(chest_scene, cell, chest_z_index)


func spawn_scene_at_cell(scene: PackedScene, cell: Vector2i, z_value: int) -> void:
	if scene == null:
		push_warning("LevelManager: spawn scene is not assigned.")
		return

	var instance = scene.instantiate()
	object_container.add_child(instance)

	instance.position = get_tile_center(cell)
	instance.z_index = z_value

	if instance is Enemy:
		setup_enemy(instance)

	print("Spawned object at cell: ", cell, " position: ", instance.position)


func setup_enemy(enemy: Enemy) -> void:
	enemy.target = player as Player

	if enemy.target == null:
		push_warning("LevelManager: player is not a Player class. Enemy target was not assigned.")
		return

	if enemy.enemy_state_machine == null:
		enemy.enemy_state_machine = enemy.get_node_or_null("EnemyStateMachine")

	if enemy.enemy_state_machine == null:
		push_warning("LevelManager: EnemyStateMachine was not found on spawned enemy.")
	else:
		print("Enemy state machine connected.")

	enemy.find_player()

	print("Enemy target assigned: ", enemy.target.name)


func remove_2x2_area_from_cells(cells: Array[Vector2i], top_left_cell: Vector2i) -> void:
	var occupied_cells: Array[Vector2i] = [
		top_left_cell,
		top_left_cell + Vector2i(1, 0),
		top_left_cell + Vector2i(0, 1),
		top_left_cell + Vector2i(1, 1)
	]

	for cell in occupied_cells:
		cells.erase(cell)


func get_tile_center(cell: Vector2i) -> Vector2:
	var tilemap = map_generator.tilemap_layer
	return tilemap.map_to_local(cell)


func get_2x2_center(cell: Vector2i) -> Vector2:
	var tilemap = map_generator.tilemap_layer
	var tile_size: Vector2 = Vector2(tilemap.tile_set.tile_size)

	return tilemap.map_to_local(cell) + tile_size / 2.0
