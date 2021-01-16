extends "res://Scenes/Items/ItemController.gd"

export var plant_type: String

var created_at: int
var data: Dictionary
var is_inventory: bool = false
var current_growth_stage: int = -1
var original_position: Vector2

onready var water_tile: TileMap = find_node("WaterTile")
onready var plant_type_id: String = InventoryItems.get_hash_from_int(
	PlantData.plant_item_type_map[plant_type]
)
onready var growth_stages: Array = InventoryItems.plant_growth_stages[plant_type_id]


func _ready():
	original_position = position
	current_growth_stage = determine_growth_stage()

	if (
		! data.empty()
		&& data.waterHistory.size() > current_growth_stage - 1
		&& data.waterHistory[current_growth_stage - 1] > 0
	):
		call_deferred("water")

	for growth_stage in range(growth_stages.size()):
		var stage_node = find_node("Stage%s" % [growth_stage + 1])
		stage_node.use_parent_material = true

	setup_growth_stage()

	GameTime.connect("daybreak_event", self, "dry_water_and_grow_plant_if_needed")


func setup_growth_stage():
	for growth_stage in range(growth_stages.size()):
		var stage_node = find_node("Stage%s" % [growth_stage + 1])
		stage_node.hide()

	var growth_stage

	if is_harvestable():
		growth_stage = find_node("Stage%s" % [growth_stages.size()])
		highlight()
	else:
		growth_stage = find_node("Stage%s" % [current_growth_stage])

	if growth_stage != null:
		growth_stage.show()

	call_deferred("position_seeds_under_players")


func _enter_tree():
	if current_growth_stage != -1 && is_harvestable():
		find_node("Stage%s" % [growth_stages.size()]).show()
		highlight()


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

	if ! farm_grid.plant_scenes.has(Vector2(int(data.x), int(data.y))):
		print_debug("Can't find plant scene, not allowing harvest")
		return

	var quantity = determine_harvest_quantity()

	bag.add_item_locally(PlantData.plant_item_type_map[plant_type], quantity)

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


func determine_harvest_quantity():
	var times_watered = 0
	var max_stages = 0

	for w in data.waterHistory:
		times_watered += w

	for g in growth_stages:
		max_stages += g

	return clamp(
		ceil(InventoryItems.plant_max_yields[plant_type_id] * float(times_watered / max_stages)),
		1,
		InventoryItems.plant_max_yields[plant_type_id]
	)


func water():
	data.waterHistory[determine_growth_stage() - 1] = 1
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
	is_inventory = true

	for i in range(7):
		var node = find_node("Stage%s" % (i + 1))
		if node != null:
			node.hide()

	var inventory_tile = find_node("InventoryTile")
	highlight(false)
	inventory_tile.show()


func is_harvestable():
	return current_growth_stage >= growth_stages.size()


func determine_growth_stage():
	var growth_stage_idx = 1
	var day_counter = 0
	var days_passed_since_created_at = GameTime.number_of_game_days_from_daybreak_from_unix_timestamp(
		created_at
	)

	for i in range(growth_stages.size()):
		day_counter += growth_stages[i]

		if days_passed_since_created_at >= day_counter:
			growth_stage_idx = i + 1
		else:
			break

	# adding another one if it's "passed" all growth stages and thusly this will trigger IsHarvestable() to return true
	if days_passed_since_created_at > day_counter:
		growth_stage_idx += 1

	return growth_stage_idx


func position_seeds_under_players():
	var current_stage: Node2D = find_node("Stage%s" % current_growth_stage)

	if current_growth_stage == 1 && position == original_position:
		current_stage.position = current_stage.position + Vector2(0, 32)
		water_tile.position = current_stage.position
		position = original_position - Vector2(0, 32)
	else:
		water_tile.position = Vector2(0, 0)
		position = original_position


func dry_water_and_grow_plant_if_needed():
	if is_inventory:
		return

	dry()

	current_growth_stage = determine_growth_stage()

	setup_growth_stage()
