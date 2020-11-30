extends "res://Scenes/Items/ItemController.gd"

const MAX_POURS: int = 10
const FULL_PAIL_TILE_NAME: String = "Items/Tools/Bucket Full"
const EMPTY_PAIL_TILE_NAME: String = "Items/Tools/Bucket Empty"

var pours_left: int

var full_pail_idx: int
var empty_pail_idx: int


func _ready():
	full_pail_idx = tile_map.tile_set.find_tile_by_name(FULL_PAIL_TILE_NAME)
	empty_pail_idx = tile_map.tile_set.find_tile_by_name(EMPTY_PAIL_TILE_NAME)

	fill_pail()


func primary_action():
	if Player.is_over_water_source && pours_left < MAX_POURS:
		fill_pail()
	elif pours_left > 0 && Player != null && Player.current_farm_grid != null:
		var tile_pos = MoveTarget.get_current_farm_grid_tile()
		var farm_grid = Player.current_farm_grid
		var farm_data = farm_grid.data

		var plant

		for p in farm_data.plants:
			var position = Vector2(p.position.x, p.position.y)

			if position == tile_pos:
				plant = p

		if plant == null:
			return

		pour_and_empty_when_needed()

		MatchEvent.farming(
			{
				"type": FarmEvent.WATER,
				"avatar": SaveData.current_avatar_key,
				"farm_owner_id": farm_grid.owner_id,
				"farm_owner_avatar": farm_grid.owner_avatar_name,
				"farm_collection": farm_grid.collection_name,
				"x": String(plant.position.x),
				"y": String(plant.position.y),
				"metadata": plant.plantType
			}
		)


#   if (
#     SessionManager.match == null &&
#     await farmData.Water(
#       plant.position,
#       plant.plantType
#     ) == false
#   )
#     new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
# }
#


func fill_pail():
	tile_map.set_cellv(Vector2(), full_pail_idx)
	pours_left = MAX_POURS


func pour_and_empty_when_needed():
	pours_left -= 1

	if pours_left == 0:
		tile_map.set_cellv(Vector2(), empty_pail_idx)
