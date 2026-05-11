extends Node2D
class_name RandomEvent

enum EventType {
	LARGE_ENEMY,
	TREASURE_ROOM
}

signal event_finished

@export var large_enemy_scene: PackedScene
@export var chest_scene: PackedScene

@export var random_event_entry_scene: PackedScene

@export var large_enemy_reward: int = 50
@export var large_enemy_scale: Vector2 = Vector2(1.8, 1.8)

@export var chest_count: int = 5
@export var min_chest_distance: float = 48.0

@export var floor_source_id: int = 1
@export var floor_atlas_coords: Vector2i = Vector2i(1, 6)

@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var player_spawn_point: Marker2D = $PlayerSpawnPoint
@onready var enemy_spawn_point: Marker2D = $EnemySpawnPoint
@onready var enemy_container: Node2D = $EnemyContainer
@onready var chest_container: Node2D = $ChestContainer
@onready var item_container: Node2D = $ItemContainer

# Add this Marker2D to your RandomEvent scene.
# This is where the portal appears after the event is cleared.
@onready var exit_spawn_point: Marker2D = get_node_or_null("ExitSpawnPoint") as Marker2D

# Optional. If you do not have this node, the portal will be added to RandomEvent directly.
@onready var entry_container: Node2D = get_node_or_null("EntryContainer") as Node2D

var player: Player = null
var selected_event: EventType

var event_started: bool = false
var event_cleared: bool = false
var exit_spawned: bool = false

var active_enemy: Node2D = null
var spawned_chests: Array[Node] = []


func _ready() -> void:
	randomize()

	player = get_tree().get_first_node_in_group("player") as Player

	if player != null:
		player.global_position = player_spawn_point.global_position
	else:
		push_warning("RandomEvent: Could not find player. Make sure Player is in the 'player' group.")

	# No waiting, no pause, no popup delay.
	start_random_event_sequence()


func _process(_delta: float) -> void:
	if not event_started:
		return

	if event_cleared:
		return

	match selected_event:
		EventType.LARGE_ENEMY:
			check_large_enemy_cleared()

		EventType.TREASURE_ROOM:
			check_treasure_room_cleared()


func start_random_event_sequence() -> void:
	if event_started:
		return

	event_started = true
	selected_event = choose_random_event()

	print("Random event selected:", selected_event)

	start_selected_event()


func choose_random_event() -> EventType:
	var roll := randf()

	if roll < 0.5:
		return EventType.LARGE_ENEMY
	else:
		return EventType.TREASURE_ROOM


func start_selected_event() -> void:
	match selected_event:
		EventType.LARGE_ENEMY:
			start_large_enemy_event()

		EventType.TREASURE_ROOM:
			start_treasure_room_event()


func start_large_enemy_event() -> void:
	print("Random Event: Large enemy event started.")

	if large_enemy_scene == null:
		push_warning("RandomEvent: large_enemy_scene is missing.")
		return

	var enemy := large_enemy_scene.instantiate() as Node2D
	enemy_container.add_child(enemy)

	enemy.global_position = enemy_spawn_point.global_position
	enemy.scale = large_enemy_scale

	active_enemy = enemy

	# Option 1: Enemy has its own died signal.
	if enemy.has_signal("died"):
		enemy.died.connect(_on_large_enemy_died)
		return

	# Option 2: Enemy has HealthComponent with died signal.
	var health := enemy.get_node_or_null("HealthComponent")
	if health != null and health.has_signal("died"):
		health.died.connect(_on_large_enemy_died)
		return

	push_warning("RandomEvent: enemy does not have a died signal or HealthComponent.died signal.")


func check_large_enemy_cleared() -> void:
	if active_enemy == null:
		complete_event()
		return

	if not is_instance_valid(active_enemy):
		complete_event()
		return


func _on_large_enemy_died(_enemy: Node = null) -> void:
	print("Random Event: Large enemy defeated.")

	if player != null and player.has_method("add_coins"):
		player.add_coins(large_enemy_reward)
	else:
		push_warning("RandomEvent: Player does not have add_coins(amount).")

	complete_event()


func start_treasure_room_event() -> void:
	print("Random Event: Treasure room started.")

	if chest_scene == null:
		push_warning("RandomEvent: chest_scene is missing.")
		return

	var floor_positions := get_floor_world_positions()

	if floor_positions.is_empty():
		push_warning("RandomEvent: No valid floor tiles found for chest spawning.")
		return

	floor_positions.shuffle()

	var used_positions: Array[Vector2] = []
	spawned_chests.clear()

	for position in floor_positions:
		if used_positions.size() >= chest_count:
			break

		if not is_position_far_enough(position, used_positions):
			continue

		if position.distance_to(player_spawn_point.global_position) < min_chest_distance:
			continue

		var chest := chest_scene.instantiate()
		chest_container.add_child(chest)
		chest.global_position = position

		# If your chest has an exported variable named item_container,
		# this safely assigns it.
		if object_has_property(chest, "item_container"):
			chest.set("item_container", item_container)

		spawned_chests.append(chest)
		used_positions.append(position)

	print("Spawned %d chests." % used_positions.size())

	if spawned_chests.is_empty():
		complete_event()


func check_treasure_room_cleared() -> void:
	if spawned_chests.is_empty():
		return

	for chest in spawned_chests:
		if not is_chest_cleared(chest):
			return

	print("Random Event: All chests cleared.")
	complete_event()


func is_chest_cleared(chest: Node) -> bool:
	if chest == null:
		return true

	if not is_instance_valid(chest):
		return true

	# If your chest is removed from scene after opening.
	if not chest.is_inside_tree():
		return true

	# Your current treasure chest uses Interactable.
	# When opened, interactable.is_interactable becomes false.
	var interactable := chest.get_node_or_null("Interactable")
	if interactable != null:
		if object_has_property(interactable, "is_interactable"):
			if interactable.get("is_interactable") == false:
				return true

	# Your current treasure chest also uses AnimatedSprite2D.
	# If animation becomes opened_chest, count it as cleared.
	var sprite := chest.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite != null:
		if sprite.animation == "opened_chest":
			return true

	return false


func complete_event() -> void:
	if event_cleared:
		return

	event_cleared = true

	print("Random Event: Event cleared. Spawning exit portal.")

	spawn_exit_entry()

	event_finished.emit()


func spawn_exit_entry() -> void:
	if exit_spawned:
		return

	exit_spawned = true

	if random_event_entry_scene == null:
		push_warning("RandomEvent: random_event_entry_scene is missing.")
		return

	var entry := random_event_entry_scene.instantiate() as Node2D

	var parent: Node = self
	if entry_container != null:
		parent = entry_container

	parent.add_child(entry)

	if exit_spawn_point != null:
		entry.global_position = exit_spawn_point.global_position
	else:
		entry.global_position = player_spawn_point.global_position + Vector2(0, -64)
		push_warning("RandomEvent: ExitSpawnPoint is missing. Portal spawned near player spawn.")

	# Add it here
	if entry.has_method("set_as_next_floor_exit"):
		entry.set_as_next_floor_exit()

	setup_exit_entry_interaction(entry)


func setup_exit_entry_interaction(entry: Node) -> void:
	var interactable := entry.get_node_or_null("Interactable")

	if interactable == null:
		push_warning("RandomEvent: Spawned entry has no Interactable child.")
		return

	interactable.interact_name = "Go to next floor"
	interactable.is_interactable = true
	interactable.interact = _on_exit_entry_interact

	if entry.has_method("set_as_next_floor_exit"):
		entry.set_as_next_floor_exit()

func _on_exit_entry_interact() -> void:
	var level_manager := get_tree().get_first_node_in_group("level_manager")

	if level_manager != null and level_manager.has_method("next_floor"):
		level_manager.next_floor()
	else:
		push_warning("RandomEvent: Cannot find LevelManager or next_floor().")


func get_floor_world_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []

	if tilemap_layer == null:
		return positions

	for cell in tilemap_layer.get_used_cells():
		var source_id := tilemap_layer.get_cell_source_id(cell)
		var atlas_coords := tilemap_layer.get_cell_atlas_coords(cell)

		if source_id == floor_source_id and atlas_coords == floor_atlas_coords:
			var local_pos := tilemap_layer.map_to_local(cell)
			var world_pos := tilemap_layer.to_global(local_pos)
			positions.append(world_pos)

	return positions


func is_position_far_enough(position: Vector2, used_positions: Array[Vector2]) -> bool:
	for used_position in used_positions:
		if position.distance_to(used_position) < min_chest_distance:
			return false

	return true


func object_has_property(object: Object, property_name: String) -> bool:
	if object == null:
		return false

	for property in object.get_property_list():
		if property.name == property_name:
			return true

	return false
