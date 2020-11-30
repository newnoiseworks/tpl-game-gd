extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	var farm_grid = Player.current_farm_grid

	if farm_grid == null:
		return

	var farm_data = farm_grid.data
	var grid_position: Vector2 = MoveTarget.get_current_farm_grid_tile()

	var stone

	for i in farm_data.forageItems:
		var position = Vector2(i.position.x, i.position.y)
		if position == grid_position && i.type == ForageItems.STONE:
			stone = i

	if stone != null:
		if (
			farm_grid.is_user_owner() == false
			&& farm_grid.get_permissions(SessionManager.session.user_id).forage != 1
		):
			TPLG.ui.show_toast("You don't have permission to forage on this farm!")
		else:
			send_forage_action(grid_position)
	elif farm_grid.is_tile_tilled(grid_position) && farm_grid.has_farm_item(grid_position) == false:
		if farm_grid.is_user_owner() == false && farm_grid.get_permissions().till != 1:
			TPLG.ui.show_toast("You don't have permission to till soil on this farm!")
		else:
			send_detill_action(grid_position)


func send_detill_action(grid_position: Vector2):
	var farm_grid = Player.current_farm_grid

	MatchEvent.farming(
		{
			"type": FarmEvent.DETILL,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(grid_position.x),
			"y": String(grid_position.y),
		}
	)


#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Detill,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Detill(
#           gridPosition
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }


func send_forage_action(grid_position):
	var farm_grid = Player.current_farm_grid

	MatchEvent.farming(
		{
			"type": FarmEvent.FORAGE,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(grid_position.x),
			"y": String(grid_position.y),
			"metadata": String(int(ForageItems.STONE))
		}
	)
#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Forage,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         ((int)ForageItemData.Type.Stone).ToString()
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Forage(
#           gridPosition,
#           ((int)ForageItemData.Type.Stone).ToString()
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
