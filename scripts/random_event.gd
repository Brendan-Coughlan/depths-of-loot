extends Node2D
class_name RandomEvent

enum EventType {
	LARGE_ENEMY,
	TREASURE_ROOM
}

signal event_finished

@export var large_enemy_scene: PackedScene
@export var chest_scene: PackedScene

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
@onready var popup_ui: FloorPopupUI = $FloorPopupUI

var player: Player = null
var selected_event: EventType
var event_started: bool = false
var active_enemy: Node2D = null


func _ready() -> void:
	# RandomEvent must still run while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	randomize()

	player = get_tree().get_first_node_in_group("player") as Player

	if player != null:
		player.global_position = player_spawn_point.global_position
	else:
		push_warning("RandomEvent: Could not find player. Make sure Player is in the 'player' group.")

	start_random_event_sequence()


func start_random_event_sequence() -> void:
	if event_started:
		return

	event_started = true

	selected_event = choose_random_event()
	var message := get_event_message(selected_event)

	print("Random event selected:", selected_event)
	print("Pause start:", Time.get_ticks_msec())

	get_tree().paused = true

	if popup_ui != null:
		popup_ui.show_event_message(message)
	else:
		push_warning("RandomEvent: FloorPopupUI is missing.")

	# This timer works while the game is paused because the second argument is true.
	await get_tree().create_timer(5.0, true).timeout

	if popup_ui != null:
		await popup_ui.hide_event_message()

	get_tree().paused = false

	print("Pause end:", Time.get_ticks_msec())

	start_selected_event()


func choose_random_event() -> EventType:
	var roll := randf()

	if roll < 0.5:
		return EventType.LARGE_ENEMY
	else:
		return EventType.TREASURE_ROOM


func get_event_message(event_type: EventType) -> String:
	match event_type:
		EventType.LARGE_ENEMY:
			return "Mini Boss Room!\nDefeat the larger enemy to gain 50 coins."
		EventType.TREASURE_ROOM:
			return "Treasure Room!\nMany chests have appeared."

	return "Random Event!"


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

	var enemy := large_enemy_scene.instantiate()
	enemy_container.add_child(enemy)

	enemy.global_position = enemy_spawn_point.global_position
	enemy.scale = large_enemy_scale
	active_enemy = enemy

	if enemy.has_signal("died"):
		enemy.died.connect(_on_large_enemy_died)
	else:
		push_warning("RandomEvent: enemy does not have a 'died' signal.")


func _on_large_enemy_died(enemy: Node = null) -> void:
	print("Random Event: Large enemy defeated.")

	if player != null and player.has_method("add_coins"):
		player.add_coins(large_enemy_reward)
	else:
		push_warning("RandomEvent: Player does not have add_coins(amount).")

	event_finished.emit()


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

		if "item_container" in chest:
			chest.item_container = item_container

		used_positions.append(position)

	print("Spawned %d chests." % used_positions.size())

	event_finished.emit()


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
