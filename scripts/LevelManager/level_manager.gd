extends Node
class_name LevelManager

@export var map_generator: MapGenerator
@export var entry_scene: PackedScene

# Two different exits
@export var normal_exit_scene: PackedScene
@export var dungeon_exit_scene: PackedScene

# Random event system
@export var random_event_entry_scene: PackedScene
@export var random_event_room_scene: PackedScene
@export_range(0.0, 1.0, 0.01) var random_event_chance: float = 0.5
@export var random_event_entry_offset_from_exit: Vector2 = Vector2(32, 0)

@export var object_container: Node2D
@export var player: CharacterBody2D

# Add all enemy scenes in the Inspector.
@export var enemy_scenes: Array[PackedScene] = []

# Boss room settings
@export var boss_floor: int = 5
@export var boss_room_scene: PackedScene
@export var boss_scene: PackedScene

@export var chest_scene: PackedScene
@export var enemy_count: int = 5
@export var chest_count: int = 3
@export var min_spawn_distance_from_entry: int = 6

# Final floor as the boss floor
@export var max_floor: int = 5
@export var current_floor: int = 1

@export var min_entry_exit_distance: int = 10
@export var player_z_index: int = 10
@export var enemy_z_index: int = 5
@export var chest_z_index: int = 4

@export var surface_scene_path: String = "res://scenes/market.tscn"

var entry_cell: Vector2i = Vector2i.ZERO
var exit_cell: Vector2i = Vector2i.ZERO

var entry_instance: Node2D = null
var exit_instance: Node2D = null

var floor_popup_ui: FloorPopupUI = null

# Boss room variables
var boss_room_instance: Node2D = null
var current_boss: Node2D = null
var boss_defeated: bool = false

# Random event variables
var random_event_entry_instance: Node2D = null
var random_event_room_instance: Node2D = null
var random_event_entry_spawned: bool = false
var random_event_checked_this_floor: bool = false
var inside_random_event_room: bool = false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	add_to_group("level_manager")

	setup_level()

	await get_tree().process_frame
	await show_floor_popup()


func setup_level() -> void:
	if player == null:
		push_error("LevelManager: player is not assigned.")
		return

	clear_level()

	entry_instance = null
	exit_instance = null

	current_boss = null
	boss_defeated = false

	random_event_entry_instance = null
	random_event_entry_spawned = false
	random_event_checked_this_floor = false
	inside_random_event_room = false

	if current_floor == boss_floor:
		setup_boss_room()
	else:
		setup_normal_dungeon()


# -------------------------------------------------------------------------
# Normal dungeon
# -------------------------------------------------------------------------

func setup_normal_dungeon() -> void:
	if map_generator == null:
		push_error("LevelManager: map_generator is not assigned.")
		return

	if object_container == null:
		push_error("LevelManager: object_container is not assigned.")
		return

	map_generator.visible = true

	map_generator.generate_map()
	choose_entry_and_exit()
	spawn_entry()
	spawn_normal_exit()
	place_player()
	spawn_random_objects()


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

	entry_instance = entry_scene.instantiate() as Node2D

	if entry_instance == null:
		push_error("LevelManager: entry_scene root must be Node2D or inherit from Node2D.")
		return

	object_container.add_child(entry_instance)

	entry_instance.position = get_2x2_center(entry_cell)
	entry_instance.z_index = chest_z_index

	print("Entry spawned at: ", entry_instance.position)


func spawn_normal_exit() -> void:
	if normal_exit_scene == null:
		push_warning("LevelManager: normal_exit_scene is not assigned.")
		return

	exit_instance = normal_exit_scene.instantiate() as Node2D

	if exit_instance == null:
		push_error("LevelManager: normal_exit_scene root must be Node2D or inherit from Node2D.")
		return

	object_container.add_child(exit_instance)

	exit_instance.position = get_2x2_center(exit_cell)
	exit_instance.z_index = chest_z_index

	print("Normal floor exit spawned at: ", exit_instance.position)


func place_player() -> void:
	if player == null:
		push_error("LevelManager: player is not assigned.")
		return

	if entry_instance == null:
		push_error("LevelManager: entry_instance is null. Cannot place player.")
		return

	var spawn_point: Marker2D = entry_instance.get_node_or_null("PlayerSpawnPoint") as Marker2D

	if spawn_point == null:
		push_warning("LevelManager: PlayerSpawnPoint was not found inside entry scene. Using entry position instead.")
		player.global_position = entry_instance.global_position
	else:
		player.global_position = spawn_point.global_position

		var player_anchor: Marker2D = player.get_node_or_null("SpawnAnchor") as Marker2D

		if player_anchor != null:
			var offset: Vector2 = spawn_point.global_position - player_anchor.global_position
			player.global_position += offset

			print("PlayerSpawnPoint global position: ", spawn_point.global_position)
			print("Player SpawnAnchor global position after correction: ", player_anchor.global_position)
		else:
			push_warning("LevelManager: Player SpawnAnchor was not found. Using player root origin.")

	player.z_index = player_z_index

	if not player.is_in_group("player"):
		player.add_to_group("player")

	print("Player spawned at root position: ", player.global_position)


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

		if enemy_scenes.is_empty():
			push_warning("LevelManager: enemy_scenes is empty. Add enemy scenes in the Inspector.")
			return

		var cell: Vector2i = available_cells.pop_back()
		var random_enemy_scene: PackedScene = enemy_scenes.pick_random()

		spawn_scene_at_cell(random_enemy_scene, cell, enemy_z_index)

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

	if instance == null:
		push_warning("LevelManager: failed to instantiate scene.")
		return

	object_container.add_child(instance)

	if instance is Node2D:
		instance.position = get_tile_center(cell)
		instance.z_index = z_value
	else:
		push_warning("LevelManager: spawned scene root is not Node2D.")
		return

	if instance is Enemy:
		instance.add_to_group("enemies")
		setup_enemy(instance as Enemy, true)
	else:
		print("Spawned object is not Enemy: ", instance.name)

	print("Spawned object at cell: ", cell, " position: ", instance.position)


func setup_enemy(enemy: Enemy, connect_random_event_check: bool = true) -> void:
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

	if connect_random_event_check:
		connect_enemy_death_to_random_event_check(enemy)

	print("Enemy target assigned: ", enemy.target.name)


func connect_enemy_death_to_random_event_check(enemy: Enemy) -> void:
	var health = enemy.get_node_or_null("HealthComponent")

	if health == null:
		push_warning("LevelManager: Enemy HealthComponent was not found. Random event check cannot connect.")
		return

	if not health.has_signal("died"):
		push_warning("LevelManager: Enemy HealthComponent does not have died signal.")
		return

	if not health.died.is_connected(_on_normal_enemy_died.bind(enemy)):
		health.died.connect(_on_normal_enemy_died.bind(enemy))

	print("Connected enemy death signal for random event check: ", enemy.name)


# -------------------------------------------------------------------------
# Random event system
# -------------------------------------------------------------------------

func _on_normal_enemy_died(enemy: Node = null) -> void:
	print("LevelManager detected enemy died.")

	if inside_random_event_room:
		print("Ignoring enemy death because player is inside random event room.")
		return

	if current_floor == boss_floor:
		print("Ignoring enemy death because this is boss floor.")
		return

	if enemy != null and is_instance_valid(enemy):
		enemy.remove_from_group("enemies")
		print("Removed dead enemy from enemies group: ", enemy.name)

	await get_tree().process_frame
	await get_tree().process_frame

	check_random_event_after_enemy_clear()


func check_random_event_after_enemy_clear() -> void:
	print("Checking random event after enemy clear...")

	if random_event_checked_this_floor:
		print("Random event was already checked this floor.")
		return

	if not are_all_normal_floor_enemies_dead():
		print("Not all enemies are dead yet.")
		return

	random_event_checked_this_floor = true

	var roll := randf()
	print("Random event roll: ", roll)

	if roll <= random_event_chance:
		print("Random event appeared.")
		spawn_random_event_entry_near_exit()

		if floor_popup_ui == null:
			floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

		if floor_popup_ui != null:
			floor_popup_ui.show_event_message("A strange portal appeared...")
	else:
		print("Random event did not appear this floor.")


func are_all_normal_floor_enemies_dead() -> bool:
	var enemies := get_tree().get_nodes_in_group("enemies")

	print("Enemies still in group: ", enemies.size())

	for enemy in enemies:
		if enemy == null:
			continue

		if not is_instance_valid(enemy):
			continue

		if enemy.is_in_group("boss"):
			continue

		if enemy.is_queued_for_deletion():
			continue

		var health = enemy.get_node_or_null("HealthComponent")

		if health != null:
			if "current_health" in health:
				if health.current_health <= 0:
					continue

		print("Still alive enemy found: ", enemy.name)
		return false

	return true


func spawn_random_event_entry_near_exit() -> void:
	if random_event_entry_spawned:
		print("Random event entry already spawned.")
		return

	if random_event_entry_scene == null:
		push_error("LevelManager: random_event_entry_scene is not assigned.")
		return

	if object_container == null:
		push_error("LevelManager: object_container is not assigned.")
		return

	if exit_instance == null:
		push_error("LevelManager: exit_instance is null. Cannot spawn random event entry.")
		return

	random_event_entry_instance = random_event_entry_scene.instantiate() as Node2D

	if random_event_entry_instance == null:
		push_error("LevelManager: random_event_entry_scene root must be Node2D.")
		return

	object_container.add_child(random_event_entry_instance)

	random_event_entry_instance.global_position = exit_instance.global_position + random_event_entry_offset_from_exit
	random_event_entry_instance.z_index = chest_z_index

	if random_event_entry_instance is RandomEventEntry:
		var random_entry := random_event_entry_instance as RandomEventEntry
		random_entry.mode = RandomEventEntry.EntryMode.TO_RANDOM_EVENT
		random_entry.level_manager = self
	else:
		if "level_manager" in random_event_entry_instance:
			random_event_entry_instance.level_manager = self

	random_event_entry_spawned = true

	print("Random event entry spawned at: ", random_event_entry_instance.global_position)


func enter_random_event_room() -> void:
	if random_event_room_scene == null:
		push_error("LevelManager: random_event_room_scene is not assigned.")
		return

	print("Entering random event room.")

	inside_random_event_room = true

	if map_generator != null:
		map_generator.visible = false

	if object_container != null:
		for child in object_container.get_children():
			child.queue_free()

	random_event_room_instance = random_event_room_scene.instantiate() as Node2D

	if random_event_room_instance == null:
		push_error("LevelManager: random_event_room_scene root must be Node2D.")
		return

	add_child(random_event_room_instance)

	var player_spawn: Marker2D = random_event_room_instance.get_node_or_null("PlayerSpawnPoint") as Marker2D

	if player_spawn != null:
		place_player_at_marker(player_spawn)
	else:
		push_warning("RandomEventRoom: PlayerSpawnPoint was not found. Player moved to room origin.")
		player.global_position = random_event_room_instance.global_position

	if random_event_room_instance.has_method("setup"):
		random_event_room_instance.setup(self)
	else:
		push_warning("RandomEventRoom does not have setup(level_manager) function.")

	if floor_popup_ui == null:
		floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

	if floor_popup_ui != null:
		floor_popup_ui.show_event_message("Random Event\nClear the room!")


func on_random_event_room_cleared() -> void:
	print("Random event room cleared.")

	if random_event_room_instance == null:
		push_error("LevelManager: random_event_room_instance is null.")
		return

	var exit_spawn: Marker2D = random_event_room_instance.get_node_or_null("EventExitSpawnPoint") as Marker2D

	if exit_spawn == null:
		push_error("RandomEventRoom: EventExitSpawnPoint was not found.")
		return

	spawn_random_event_exit_to_next_floor(exit_spawn)

	if floor_popup_ui == null:
		floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

	if floor_popup_ui != null:
		floor_popup_ui.show_event_message("Event cleared!\nPortal opened")


func spawn_random_event_exit_to_next_floor(exit_spawn: Marker2D) -> void:
	if random_event_entry_scene == null:
		push_error("LevelManager: random_event_entry_scene is not assigned.")
		return

	var event_exit := random_event_entry_scene.instantiate() as Node2D

	if event_exit == null:
		push_error("LevelManager: random_event_entry_scene root must be Node2D.")
		return

	random_event_room_instance.add_child(event_exit)

	event_exit.global_position = exit_spawn.global_position
	event_exit.z_index = chest_z_index

	if event_exit is RandomEventEntry:
		var random_entry := event_exit as RandomEventEntry
		random_entry.mode = RandomEventEntry.EntryMode.TO_NEXT_FLOOR
		random_entry.level_manager = self
	else:
		if "level_manager" in event_exit:
			event_exit.level_manager = self

	print("Random event exit portal spawned at: ", event_exit.global_position)


func leave_random_event_and_go_next_floor() -> void:
	print("Leaving random event room and going to next floor.")

	inside_random_event_room = false

	if random_event_room_instance != null:
		random_event_room_instance.queue_free()
		random_event_room_instance = null

	next_floor()


# -------------------------------------------------------------------------
# Boss room
# -------------------------------------------------------------------------

func setup_boss_room() -> void:
	print("Loading boss room on floor: ", current_floor)

	if boss_room_scene == null:
		push_error("LevelManager: boss_room_scene is not assigned.")
		return

	if boss_scene == null:
		push_error("LevelManager: boss_scene is not assigned.")
		return

	if dungeon_exit_scene == null:
		push_error("LevelManager: dungeon_exit_scene is not assigned.")
		return

	if map_generator != null:
		map_generator.visible = false

	boss_room_instance = boss_room_scene.instantiate() as Node2D

	if boss_room_instance == null:
		push_error("LevelManager: boss_room_scene root must be Node2D.")
		return

	add_child(boss_room_instance)

	var player_spawn: Marker2D = boss_room_instance.get_node_or_null("PlayerSpawnPoint") as Marker2D
	var boss_spawn: Marker2D = boss_room_instance.get_node_or_null("BossSpawnPoint") as Marker2D
	var exit_spawn: Marker2D = boss_room_instance.get_node_or_null("ExitSpawnPoint") as Marker2D
	var boss_container: Node2D = boss_room_instance.get_node_or_null("BossContainer") as Node2D
	var boss_object_container: Node2D = boss_room_instance.get_node_or_null("ObjectContainer") as Node2D

	if player_spawn == null:
		push_error("BossRoom: PlayerSpawnPoint was not found.")
		return

	if boss_spawn == null:
		push_error("BossRoom: BossSpawnPoint was not found.")
		return

	if exit_spawn == null:
		push_error("BossRoom: ExitSpawnPoint was not found.")
		return

	if boss_container == null:
		push_error("BossRoom: BossContainer was not found.")
		return

	if boss_object_container == null:
		push_error("BossRoom: ObjectContainer was not found.")
		return

	place_player_at_marker(player_spawn)
	spawn_boss(boss_spawn, boss_container)
	spawn_boss_room_dungeon_exit(exit_spawn, boss_object_container)

	if floor_popup_ui == null:
		floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

	if floor_popup_ui != null:
		floor_popup_ui.show_event_message("Boss Room\nDefeat the boss!")


func spawn_boss(boss_spawn: Marker2D, boss_container: Node2D) -> void:
	current_boss = boss_scene.instantiate() as Node2D

	if current_boss == null:
		push_error("LevelManager: boss_scene root must be Node2D.")
		return

	boss_container.add_child(current_boss)

	current_boss.global_position = boss_spawn.global_position
	current_boss.z_index = enemy_z_index
	current_boss.add_to_group("enemies")
	current_boss.add_to_group("boss")

	if current_boss is Enemy:
		setup_enemy(current_boss as Enemy, false)
	else:
		if "target" in current_boss:
			current_boss.target = player

	connect_boss_death_signal(current_boss)

	print("Boss spawned at: ", current_boss.global_position)


func connect_boss_death_signal(boss: Node2D) -> void:
	var health = boss.get_node_or_null("HealthComponent")

	if health == null:
		push_warning("LevelManager: Boss HealthComponent was not found. Boss death cannot open door.")
		return

	if health.has_signal("died"):
		if not health.died.is_connected(_on_boss_died):
			health.died.connect(_on_boss_died)
	else:
		push_warning("LevelManager: Boss HealthComponent does not have died signal.")


func spawn_boss_room_dungeon_exit(exit_spawn: Marker2D, boss_object_container: Node2D) -> void:
	if dungeon_exit_scene == null:
		push_error("LevelManager: dungeon_exit_scene is not assigned.")
		return

	exit_instance = dungeon_exit_scene.instantiate() as Node2D

	if exit_instance == null:
		push_error("LevelManager: dungeon_exit_scene root must be Node2D.")
		return

	boss_object_container.add_child(exit_instance)

	exit_instance.global_position = exit_spawn.global_position
	exit_instance.z_index = chest_z_index
	exit_instance.add_to_group("dungeon_exit")

	if exit_instance is DungeonExit:
		var dungeon_exit := exit_instance as DungeonExit
		dungeon_exit.exit_mode = DungeonExit.ExitMode.RETURN_TO_SURFACE
		dungeon_exit.surface_scene_path = surface_scene_path
		dungeon_exit.set_locked(true)
	else:
		if exit_instance.has_method("set_locked"):
			exit_instance.set_locked(true)
		else:
			push_warning("LevelManager: dungeon_exit_scene does not have set_locked(value).")

	print("Boss room dungeon exit spawned at: ", exit_instance.global_position)


func _on_boss_died() -> void:
	if boss_defeated:
		return

	boss_defeated = true

	print("Boss defeated. Dungeon door opened.")

	if exit_instance != null:
		if exit_instance.has_method("set_locked"):
			exit_instance.set_locked(false)
		else:
			push_warning("LevelManager: Boss room exit has no set_locked method.")

	if floor_popup_ui == null:
		floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

	if floor_popup_ui != null:
		floor_popup_ui.show_event_message("Boss defeated!\nDoor opened")


# -------------------------------------------------------------------------
# Player placement / floor flow
# -------------------------------------------------------------------------

func place_player_at_marker(spawn_point: Marker2D) -> void:
	if player == null:
		push_error("LevelManager: player is not assigned.")
		return

	player.global_position = spawn_point.global_position

	var player_anchor: Marker2D = player.get_node_or_null("SpawnAnchor") as Marker2D

	if player_anchor != null:
		var offset: Vector2 = spawn_point.global_position - player_anchor.global_position
		player.global_position += offset

	player.z_index = player_z_index

	if not player.is_in_group("player"):
		player.add_to_group("player")

	print("Player spawned at marker position: ", player.global_position)


func show_floor_popup() -> void:
	await get_tree().process_frame

	if floor_popup_ui == null:
		floor_popup_ui = get_tree().get_first_node_in_group("floor_popup_ui") as FloorPopupUI

	if floor_popup_ui != null:
		await floor_popup_ui.show_floor_message(current_floor, max_floor)
	else:
		push_warning("LevelManager: FloorPopupUI was not found.")


func next_floor() -> void:
	if current_floor >= max_floor:
		game_completed()
		return

	current_floor += 1
	print("Going to floor: ", current_floor)

	setup_level()

	await get_tree().process_frame
	await show_floor_popup()


func game_completed() -> void:
	print("Game completed! Returning to surface.")
	return_to_surface()


func return_to_surface() -> void:
	var main = get_tree().root.get_node_or_null("Main")

	if main != null and main.has_method("load_scene"):
		main.load_scene(surface_scene_path)
	else:
		push_warning("LevelManager: Main was not found. Cannot return to surface.")


func clear_level() -> void:
	if object_container != null:
		for child in object_container.get_children():
			child.queue_free()

	if boss_room_instance != null:
		boss_room_instance.queue_free()
		boss_room_instance = null

	if random_event_room_instance != null:
		random_event_room_instance.queue_free()
		random_event_room_instance = null

	current_boss = null
	random_event_entry_instance = null


# -------------------------------------------------------------------------
# Tile helper functions
# -------------------------------------------------------------------------

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
