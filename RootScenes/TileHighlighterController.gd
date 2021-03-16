extends TileMap

onready var highlight_tile_id = tile_set.find_tile_by_name("Environment/Street/Street 0")


func highlight(position: Vector2, end_position: Vector2):
	if position.x > end_position.x || position.y > end_position.y:
		print(
			"TileHighlightController#highlight error -- end_position must be greater in both values than position"
		)
		return

	clear()

	for x in range(abs(end_position.x - position.x)):
		for y in range(abs(end_position.y - position.y)):
			set_cellv(position + Vector2(x, y), highlight_tile_id)


func unhighlight_tile(position: Vector2):
	set_cellv(position, -1)
