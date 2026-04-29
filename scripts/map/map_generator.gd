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
	if tilemap_layer == null:
		push_error("MapGenerator: tilemap_layer is not assigned.")
		return []

	if randomize_seed:
		gen_seed = randi()

	seed(gen_seed)

	floor_cells.clear()
	enemy_spawn_cells.clear()
	tilemap_layer.clear()

	draw_walker_generation(
		map_dimensions,
		boundary_padding,
		TILE_DATA.floor.source_id,
		TILE_DATA.floor.atlas_coords
	)

	fill_empty_space_with_walls()
	build_enemy_spawn_cells()

	return floor_cells


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
		bounds = bounds.grow_side(side, -boundary_padding)

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


func fill_empty_space_with_walls() -> void:
	var floor_rect := get_floor_bounds()
	var wall_padding := 2   # controls thickness of wall border

	floor_rect = floor_rect.grow(wall_padding)

	for x in range(map_dimensions.x):
		for y in range(map_dimensions.y):
			var cell := Vector2i(x, y)

			if floor_cells.has(cell):
				continue

			if floor_rect.has_point(cell):
				set_tile(cell, "wall")
			else:
				tilemap_layer.erase_cell(cell)


func get_floor_bounds() -> Rect2i:
	if floor_cells.is_empty():
		return Rect2i()

	var min_x := floor_cells[0].x
	var max_x := floor_cells[0].x
	var min_y := floor_cells[0].y
	var max_y := floor_cells[0].y

	for cell in floor_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	var position := Vector2i(min_x, min_y)
	var size := Vector2i(max_x - min_x + 1, max_y - min_y + 1)

	return Rect2i(position, size)


func set_tile(cell: Vector2i, tile_name: String) -> void:
	var data: Dictionary = TILE_DATA[tile_name]

	tilemap_layer.set_cell(
		cell,
		data.source_id,
		data.atlas_coords
	)


func build_enemy_spawn_cells() -> void:
	enemy_spawn_cells.clear()

	for cell in floor_cells:
		enemy_spawn_cells.append(cell)


func get_floor_cells() -> Array[Vector2i]:
	return floor_cells.duplicate()


func get_enemy_spawn_cells() -> Array[Vector2i]:
	return enemy_spawn_cells.duplicate()
