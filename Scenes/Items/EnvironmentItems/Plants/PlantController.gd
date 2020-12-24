extends "res://Scenes/Items/ItemController.gd"

export var plant_type: String
export var growth_stages: Array = []

var created_at: int
var data: Dictionary

var current_growth_stage: int
var plant_type_id: String
var water_tile: TileMap


func _ready():
	if water_tile == null:
		water_tile = find_node("WaterTile")

	plant_type_id = InventoryItems.get_hash_from_int(PlantData.plant_item_type_map[plant_type])
	growth_stages = InventoryItems.plant_growth_stages[plant_type_id]
	GameTime.connect("daybreak_event", self, "dry_water_and_grow_plant_if_needed")
	current_growth_stage = determine_growth_stage()

	if (
		! data.empty()
		&& data.waterHistory.size() > current_growth_stage
		&& data.waterHistory[current_growth_stage] > 0
	):
		call_deferred("water")

	var growth_stage

	if is_harvestable():
		growth_stage = find_node("Stage%s" % [growth_stages.size()])
		highlight()
	else:
		growth_stage = find_node("Stage%s" % [current_growth_stage])

	if growth_stage != null:
		growth_stage.use_parent_material = true
		growth_stage.call_deferred("show")


func exit_tree():
	GameTime.disconnect("daybreak_event", self, "dry_water_and_grow_plant_if_needed")
	dry()

	var stage: int = 1

	while has_node("Stage%s" % [stage]):
		var node = find_node("Stage%s" % [stage])

		if node == null:
			break

		if stage > 1:
			node.hide()
		else:
			node.show()

		stage += 1


func interact():
	if ! is_harvestable() || Player.current_farm_grid == null:
		return

	var farm_grid = Player.current_farm_grid

	if farm_grid.is_user_owner() == false && farm_grid.get_permissions().harvest != 1:
		TPLG.ui.show_toast("You don't have permission to harvest crops on this farm!")
		return

	var bag = TPLG.inventory.bag

	if (
		bag.has_item(PlantData.plant_item_type_map[plant_type]) == false
		&& bag.has_empty_slot() == -1
	):
		TPLG.ui.show_toast("Inventory Full!")
		print_debug("TODO: Need to implement multi row inventory")
		return

	bag.add_item_locally(PlantData.plant_item_type_map[plant_type])

	MatchEvent.farming(
		{
			"type": FarmEvent.HARVEST,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(data.x),
			"y": String(data.y),
			"metadata": plant_type_id
		}
	)


#   if (SessionManager.match == null) HarvestRPCMethod(farmData);
# }


func water():
	water_tile.show()


func dry():
	water_tile.hide()


#     private async void HarvestRPCMethod(FarmGridData farmData) {
#       bool harvestOk = await farmData.Harvest(
#         MovementGridController.instance.GetCurrentFarmGridTile(),
#         plantTypeId
#       );

#       // if (harvestOk)
#       //   await InventoryController.instance.bag.ReloadBag();
#       // else
#       //   new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));

#       if (!harvestOk)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }

#     public async void PrimaryAction() {
#       // TODO: "eating" plants should do something? gain experience? Have text denoting refreshing state?

#       // await InventoryController.instance.bag.RemoveItemFromBag(
#       //   PlantData.plantItemTypeMap[plantType]
#       // );
#     }


func ready_for_inventory():
	for i in range(7):
		var node = find_node("Stage%s" % (i + 1))
		if node != null:
			node.hide()

	var inventory_tile = find_node("InventoryTile")
	highlight(false)
	inventory_tile.show()


func is_harvestable():
	return current_growth_stage == growth_stages.size()


func determine_growth_stage():
	var growth_stage_idx = 0
	var day_counter = 0
	var days_passed_since_created_at = GameTime.number_of_game_days_from_daybreak_from_unix_timestamp(
		created_at
	)

	for i in range(growth_stages.size()):
		day_counter += growth_stages[i]

		if days_passed_since_created_at >= day_counter:
			growth_stage_idx = i
		else:
			break

	# adding another one if it's "passed" all growth stages and thusly this will trigger IsHarvestable() to return true
	if days_passed_since_created_at > day_counter:
		growth_stage_idx += 1

	return growth_stage_idx


func dry_water_and_grow_plant_if_needed():
	dry()

	var growth_stage: int = determine_growth_stage()

	if current_growth_stage >= growth_stage:
		return

	var current_stage: Node2D = find_node("Stage%s" % current_growth_stage)
	var next_stage: Node2D = find_node("Stage%s" % growth_stage)
	var last_stage: Node2D = find_node("Stage%s" % growth_stages.size())

	if current_stage != null:
		current_stage.hide()

	if ! is_harvestable() && next_stage != null:
		next_stage.show()
		next_stage.use_parent_material = true
	elif is_harvestable() && last_stage != null:
		last_stage.show()
		last_stage.use_parent_material = true
		call_deferred("highlight")

	current_growth_stage = growth_stage
