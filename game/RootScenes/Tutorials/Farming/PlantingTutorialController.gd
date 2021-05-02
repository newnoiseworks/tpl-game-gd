extends "res://RootScenes/Tutorials/Farming/FarmingTutorialController.gd"


func _init():
	mission_key = "tutorialFarmingPlanting"
	tiles_to_highlight_size = Vector2(1, 4)
	item_idx = 6
	dialogue_dict = "JKJZ/Tutorials/SeedTutorial"
	has_highlighted_dialogue_idx = "playerHasSelectedSeeds"
	has_completed_farm_task_idx = "playerHasPlantedSeeds"
	next_tut_scene = "res://RootScenes/Tutorials/Farming/WateringTutorial.tscn"
	farm_event_idx = FarmEvent.PLANT


func _on_ready():
	._on_ready()

	farm_grid.data = {
		"forageItems": [],
		"plants": [],
		"craftedItems": [],
		"groundTiles":
		{"0": {"0": "tilled"}, "1": {"0": "tilled"}, "2": {"0": "tilled"}, "3": {"0": "tilled"}}
	}

	farm_grid.call_deferred("draw_things_from_data")

	TPLG.dialogue.start("JKJZ/Tutorials/SeedTutorial", "seedTutorialBegin")


func _synthesize_inventory():
	TPLG.inventory.bag.synthesize_bag(
		{
			"bag":
			[
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.TILLER),
					"bagPosition": 0,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.PAIL),
					"bagPosition": 1,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.PICKAXE),
					"bagPosition": 2,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.SCYTHE),
					"bagPosition": 3,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.AXE),
					"bagPosition": 4,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.FISHPOLE),
					"bagPosition": 5,
					"quantity": 1
				},
				{
					"itemTypeId": InventoryItems.get_hash_from_int(InventoryItems.POTATO_SEEDS),
					"bagPosition": 6,
					"quantity": 4
				}
			]
		}
	)
