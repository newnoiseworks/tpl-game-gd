extends Node

const tile_connector_map = {
	"TTTT": "Environment/Tilled Dirt/Tilled Dirt 9",
	"FTTT": "Environment/Tilled Dirt/Tilled Dirt 2",
	"TFTT": "Environment/Tilled Dirt/Tilled Dirt 6",
	"TTFT": "Environment/Tilled Dirt/Tilled Dirt 8",
	"TTTF": "Environment/Tilled Dirt/Tilled Dirt 5",
	"FTTF": "Environment/Tilled Dirt/Tilled Dirt 1",
	"TTFF": "Environment/Tilled Dirt/Tilled Dirt 7",
	"FFTT": "Environment/Tilled Dirt/Tilled Dirt 4",
	"TFFT": "Environment/Tilled Dirt/Tilled Dirt 14",  # needs correction
	"FTFT": "Environment/Tilled Dirt/Tilled Dirt 15",
	"TFTF": "Environment/Tilled Dirt/Tilled Dirt 18",
	"FFFT": "Environment/Tilled Dirt/Tilled Dirt 17",
	"TFFF": "Environment/Tilled Dirt/Tilled Dirt 20",
	"FFTF": "Environment/Tilled Dirt/Tilled Dirt 19",
	"FTFF": "Environment/Tilled Dirt/Tilled Dirt 16",
	"FFFF": "Environment/Tilled Dirt/Tilled Dirt 21",
}

const search_string = "Environment/Tilled Dirt/Tilled Dirt"


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
		tiles_with_tilled_dirt[i] = search_string in tiles[i]

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
