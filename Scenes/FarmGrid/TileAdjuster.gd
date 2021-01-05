extends Node

const tile_connector_map = {
	"TTTT": "tiles/tilled/slice_ground_tilled_09-",
	"FTTT": "tiles/tilled/slice_ground_tilled_02-",
	"TFTT": "tiles/tilled/slice_ground_tilled_10-",
	"TTFT": "tiles/tilled/slice_ground_tilled_20-",
	"TTTF": "tiles/tilled/slice_ground_tilled_13-",
	"FTTF": "tiles/tilled/slice_ground_tilled_01-",
	"TTFF": "tiles/tilled/slice_ground_tilled_19-",
	"FFTT": "tiles/tilled/slice_ground_tilled_04-",
	"TFFT": "tiles/tilled/slice_ground_tilled_22-",
	"FTFT": "tiles/tilled/slice_ground_tilled_25-",
	"TFTF": "tiles/tilled/slice_ground_tilled_23-",
	"FFFT": "tiles/tilled/slice_ground_tilled_26-",
	"TFFF": "tiles/tilled/slice_ground_tilled_28-",
	"FFTF": "tiles/tilled/slice_ground_tilled_17-",
	"FTFF": "tiles/tilled/slice_ground_tilled_24-",
	"FFFF": "tiles/tilled/slice_ground_tilled_27-",
}

const search_string = "tiles/tilled/slice_ground_tilled"


func till_tiled_dirt(
	ground_map: TileMap, grid_position: Vector2, data: Dictionary, second_layer: bool = false
):
	var tile_above = get_tile_namev(ground_map, grid_position + Vector2.UP)
	var tile_below = get_tile_namev(ground_map, grid_position + Vector2.DOWN)
	var tile_left = get_tile_namev(ground_map, grid_position + Vector2.LEFT)
	var tile_right = get_tile_namev(ground_map, grid_position + Vector2.RIGHT)

	var tiles = [tile_above, tile_right, tile_below, tile_left]
	var tiles_with_tilled_dirt = []

	for i in range(tiles.size()):
		tiles_with_tilled_dirt.insert(i, search_string in tiles[i])

	var tile_to_change_to = determine_tile_name_to_change_to(tiles_with_tilled_dirt)
	var tile_to_change_idx = ground_map.tile_set.find_tile_by_name(tile_to_change_to)
	ground_map.set_cellv(grid_position, tile_to_change_idx)

	update_tile_data(tile_to_change_to, grid_position, data)

	if second_layer:
		return

	for i in range(tiles_with_tilled_dirt.size()):
		if tiles_with_tilled_dirt[i]:
			var position: Vector2 = grid_position

			match i:
				0:
					position += Vector2.UP
				1:
					position += Vector2.RIGHT
				2:
					position += Vector2.DOWN
				3:
					position += Vector2.LEFT

			till_tiled_dirt(ground_map, position, data, true)


func update_tile_data(tile_name: String, grid_position: Vector2, data: Dictionary):
	if data.groundTiles.has(String(grid_position.y)) == false:
		data.groundTiles[String(grid_position.y)] = {}

	data.groundTiles[String(grid_position.y)][String(grid_position.x)] = tile_name


func determine_tile_name_to_change_to(tiles_with_tilled_dirt: Array):
	var bool_set: String = ""

	for tilled in tiles_with_tilled_dirt:
		bool_set += "T" if tilled else "F"

	return tile_connector_map[bool_set]


func get_tile_namev(ground_map: TileMap, grid_position: Vector2):
	var existing_tile: int = ground_map.get_cellv(grid_position)

	if existing_tile > -1:
		return ground_map.tile_set.tile_get_name(existing_tile)
	else:
		return ground_map.tile_set.tile_get_name(461)
