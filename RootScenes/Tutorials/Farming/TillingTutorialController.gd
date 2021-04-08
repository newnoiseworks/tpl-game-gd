extends "res://RootScenes/Tutorials/Farming/FarmingTutorialController.gd"


func _init():
	mission_key = "tutorialFarmingTilling"
	tiles_to_highlight_size = Vector2(4, 4)
	item_idx = 0
	dialogue_dict = "JKJZ/Tutorials/TillTutorial"
	has_highlighted_dialogue_idx = "playerHasSelectedTiller"
	has_completed_farm_task_idx = "playerHasTilledSoil"
	next_tut_scene = "res://RootScenes/Tutorials/Farming/PlantingTutorial.tscn"
	farm_event_idx = FarmEvent.TILL


func _on_ready():
	._on_ready()

	jkjz._move_event({"ping": "0", "x": player_entry.position.x + 16, "y": player_entry.position.y})

	timer.one_shot = true
	timer.wait_time = 3
	timer.connect("timeout", self, "_deliver_intro_dialogue")
	timer.start()


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
				}
			]
		}
	)


func _deliver_intro_dialogue():
	timer.disconnect("timeout", self, "_deliver_intro_dialogue")
	TPLG.dialogue.start("JKJZ", "tillTutorialBegin")
