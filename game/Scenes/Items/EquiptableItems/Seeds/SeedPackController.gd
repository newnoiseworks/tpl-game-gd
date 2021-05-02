extends "res://Scenes/Items/ItemController.gd"

export var type: String

onready var inventory_type: int = PlantData.seed_item_type_map[type]


func primary_action():
	if Player.current_farm_grid == null:
		return
	if can_add_plant_to(Player.current_farm_grid) == false:
		return

	var farm_grid = Player.current_farm_grid

	if farm_grid.is_user_owner() == false && farm_grid.get_permissions().plant != 1:
		TPLG.ui.show_toast("You don't have permission to plant seeds on this farm!")
		return

	TPLG.inventory.bag.remove_item_locally(inventory_type)

	MatchEvent.farming(
		{
			"type": FarmEvent.PLANT,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(MoveTarget.get_current_farm_grid_tile().x),
			"y": String(MoveTarget.get_current_farm_grid_tile().y),
			"metadata": InventoryItems.get_hash_from_int(inventory_type)
		}
	)


#       new FarmingEvent(
#         new FarmingEventArgs(
#           FarmingEventType.Plant,
#           MovementGridController.instance.GetCurrentFarmGridTile(),
#           farmData.userId,
#           farmData.avatarDataName,
#           farmData.collectionName,
#           InventoryItemIDHelper.GetHash(inventoryType)
#         ),
#         player.userId
#       );

#       if (SessionManager.match == null) PlantRPCMethod(farmData);
#     }

#     private async void PlantRPCMethod(FarmGridData farmData) {
#       bool plantOk = await farmData.Plant(
#         MovementGridController.instance.GetCurrentFarmGridTile(),
#         InventoryItemIDHelper.GetHash(inventoryType)
#       );

#       // if (plantOk)
#       // await InventoryController.instance.bag.ReloadBag();
#       // else
#       // new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));

#       if (!plantOk)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }


func can_add_plant_to(farm_grid):
	var grid_position: Vector2 = MoveTarget.get_current_farm_grid_tile()

	for plant in farm_grid.data.plants:
		if Vector2(plant.x, plant.y) == grid_position:
			return false

	var tilename = farm_grid.get_ground_map_tilename_from_position(grid_position)

	if tilename == "" || tilename == null:
		return false

	return "tiles/tilled/slice_ground_tilled" in tilename
#       return tilename.Contains(TileAdjuster.searchString);
