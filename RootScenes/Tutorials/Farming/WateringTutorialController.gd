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

	farm_grid.data = {
		"forageItems": [],
		"plants":
		[
			{
				"createdAt": String(OS.get_unix_time()),
				"plantType": InventoryItems.get_hash_from_int(InventoryItems.POTATO),
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "0"
			},
			{
				"createdAt": String(OS.get_unix_time() - 1000),
				"plantType": InventoryItems.get_hash_from_int(InventoryItems.POTATO),
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "1"
			},
			{
				"createdAt": String(OS.get_unix_time() - 2000),
				"plantType": InventoryItems.get_hash_from_int(InventoryItems.POTATO),
				"waterHistory": [0, 0, 0, 0, 0, 0],
				"x": "0",
				"y": "2"
			},
			{
				"createdAt": String(OS.get_unix_time() - 2500),
				"plantType": InventoryItems.get_hash_from_int(InventoryItems.POTATO),
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
