extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	var farm_grid = Player.current_farm_grid

	if farm_grid == null:
		return

	if farm_grid.is_user_owner() == false && farm_grid.get_permissions().forage != 1:
		TPLG.ui.show_toast("You don't have permission to forage on this farm!")

	var farm_data = farm_grid.data
	var grid_position = MoveTarget.get_current_farm_grid_tile()

	var weed_or_grass

	for i in farm_data.forageItems:
		var position = Vector2(i.position.x, i.position.y)

		if (
			position == grid_position
			&& (int(i.type) == ForageItems.WEED || int(i.type) == ForageItems.TALL_GRASS)
		):
			weed_or_grass = i

	if weed_or_grass == null:
		return

	MatchEvent.farming(
		{
			"type": FarmEvent.FORAGE,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(grid_position.x),
			"y": String(grid_position.y),
			"metadata": weed_or_grass.type
		}
	)
#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Forage,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         ((int)weedOrGrass.type).ToString()
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Forage(
#           gridPosition,
#           ((int)weedOrGrass.type).ToString()
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
