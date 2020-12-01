extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	var farm_grid = Player.current_farm_grid

	if farm_grid == null:
		return

	if farm_grid.is_user_owner() == false && farm_grid.get_permissions().till != 1:
		TPLG.ui.show_toast("You don't have permission to till soil on this farm!")

	var grid_position: Vector2 = MoveTarget.get_current_farm_grid_tile()
	var tile_name = farm_grid.get_ground_map_tilename_from_position(grid_position)

	if (
		(tile_name != null && ("Environment/Dirt/Dirt" in tile_name) == false)
		|| farm_grid.has_farm_item(grid_position)
	):
		return

	MatchEvent.farming(
		{
			"type": FarmEvent.TILL,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(grid_position.x),
			"y": String(grid_position.y),
		}
	)

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Till,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName
#       ));

#       if (SessionManager.match == null) TillRPCMethod(farmData, gridPosition);
#     }

#     public async void TillRPCMethod(FarmGridData farmData, Vector2 gridPosition) {
#       bool tillOk = await farmData.Till(
#         gridPosition
#       );

#       if (tillOk == false)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
