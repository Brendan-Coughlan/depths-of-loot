@tool
extends Node
class_name MapGenerator

const TILE_DATA: Dictionary = {
	"floor": {
		"source_id": 1,
		"atlas_coords": Vector2i(1, 6)
	},
	"wall": {
		"source_id": 1,
		"atlas_coords": Vector2i(1, 3)
	}
}

@export var gen_seed: int = 0
@export var randomize_seed: bool = true
@export var map_dimensions: Vector2i = Vector2i(40, 40)
@export var total_steps: int = 600
@export var boundary_padding: int = 4
@export_tool_button("Generate Map") var map_gen_button = generate_map
@export var tilemap_layer: TileMapLayer

var floor_cells: Array[Vector2i] = []
var enemy_spawn_cells: Array[Vector2i] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		generate_map()

func generate_map() -> Array[Vector2i]:
	if randomize_seed:
		gen_seed = randi()

	seed(gen_seed)
	floor_cells.clear()
	enemy_spawn_cells.clear()
	tilemap_layer.clear()

	draw_tile_rect(map_dimensions, TILE_DATA.wall.source_id, TILE_DATA.wall.atlas_coords)
	draw_walker_generation(
		map_dimensions,
		boundary_padding,
		TILE_DATA.floor.source_id,
		TILE_DATA.floor.atlas_coords
	)

	build_enemy_spawn_cells()

	return floor_cells

func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tilemap_layer.set_cell(Vector2i(x, y), source_id, atlas_coords)

func draw_walker_generation(dimensions: Vector2i, padding: int, source_id: int, atlas_coords: Vector2i) -> void:
	var directions: Array[Vector2i] = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]

	var cur_pos: Vector2i = Vector2i(
		floor(dimensions.x / 2.0),
		floor(dimensions.y / 2.0)
	)

	var bounds: Rect2i = Rect2i(0, 0, dimensions.x, dimensions.y)

	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		bounds = bounds.grow_side(side, -padding)

	for i in range(total_steps):
		if bounds.has_point(cur_pos):
			carve_floor(cur_pos, source_id, atlas_coords)

		var move_dir: Vector2i = directions.pick_random()
		var next_pos: Vector2i = cur_pos + move_dir

		if bounds.has_point(next_pos):
			cur_pos = next_pos
		else:
			directions.shuffle()
			for d in directions:
				if bounds.has_point(cur_pos + d):
					cur_pos += d
					break

func carve_floor(cell: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	tilemap_layer.set_cell(cell, source_id, atlas_coords)

	if not floor_cells.has(cell):
		floor_cells.append(cell)

func build_enemy_spawn_cells() -> void:
	enemy_spawn_cells.clear()

	for cell in floor_cells:
		enemy_spawn_cells.append(cell)

func get_floor_cells() -> Array[Vector2i]:
	return floor_cells.duplicate()

func get_enemy_spawn_cells() -> Array[Vector2i]:
	return enemy_spawn_cells.duplicate()
