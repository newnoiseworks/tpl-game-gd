extends "res://RootScenes/Tutorials/Farming/FarmingTutorialController.gd"


func _init():
	mission_key = "tutorialFarmingWatering"
	tiles_to_highlight_size = Vector2(1, 4)
	item_idx = 1
	dialogue_dict = "JKJZ/Tutorials/WateringTutorial"
	has_highlighted_dialogue_idx = "playerHasSelectedPail"
	has_completed_farm_task_idx = "playerHasWateredPlants"
	next_tut_scene = "res://RootScenes/Tutorials/Farming/HarvestingTutorial.tscn"
	farm_event_idx = FarmEvent.WATER


func _on_ready():
	._on_ready()

	# TODO: Need to adjust createdAt timestamps to ensure the plants are never fully harvestable at tutorial time
	farm_grid.data = {
		"forageItems": [],
		"plants":
		[
			{
				"createdAt": "1617939205",
				"plantType": "bb8e09a312941709ab85b7b147c74abc",
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "0"
			},
			{
				"createdAt": "1617939206",
				"plantType": "bb8e09a312941709ab85b7b147c74abc",
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "1"
			},
			{
				"createdAt": "1617939206",
				"plantType": "bb8e09a312941709ab85b7b147c74abc",
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "2"
			},
			{
				"createdAt": "1617939207",
				"plantType": "bb8e09a312941709ab85b7b147c74abc",
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "3"
			}
		],
		"craftedItems": [],
		"groundTiles":
		{"0": {"0": "tilled"}, "1": {"0": "tilled"}, "2": {"0": "tilled"}, "3": {"0": "tilled"}}
	}

	farm_grid.call_deferred("draw_things_from_data")

	TPLG.dialogue.start(dialogue_dict, "wateringTutorialBegin")


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
			]
		}
	)
