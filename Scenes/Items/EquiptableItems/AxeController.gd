extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	var farm_grid = Player.current_farm_grid

	if farm_grid == null:
		return

	if farm_grid.is_user_owner() == false && farm_grid.get_permissions().forage != 1:
		TPLG.ui.show_toast("You don't have permission to forage on this farm!")
		return

	var farm_data = farm_grid.data
	var grid_position = MoveTarget.get_current_farm_grid_tile()
	var tree

	for i in farm_data.forageItems:
		var position = Vector2(i.position.x, i.position.y)

		if (
			(
				position == grid_position
				|| position == grid_position - Vector2(1, 0)
				|| position == grid_position + Vector2(1, 0)
				|| position == grid_position + Vector2(0, 1)
			)
			&& i.type == ForageItems.TREE
		):
			tree = i

	if tree == null:
		return

	MatchEvent.farming(
		{
			"type": FarmEvent.HARVEST,
			"avatar": SaveData.all_avatars_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(tree.position.x),
			"y": String(tree.position.y),
			"metadata": String(int(ForageItems.TREE))
		}
	)

#  if (
#    SessionManager.match == null &&
#    await farmData.Forage(
#      tree.position,
#      ((int)ForageItemData.Type.Tree).ToString()
#     ) == false
#   )
#     new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#  }
