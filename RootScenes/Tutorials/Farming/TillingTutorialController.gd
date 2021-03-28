extends "res://RootScenes/RootController.gd"

onready var player_entry = find_node("PlayerEntry")
onready var jkjz = find_node("JKJZ")
onready var timer: Timer = find_node("Timer")
onready var farm_grid = find_node("FarmGrid")

var tiles_to_highlight: Array = []
var tiles_to_highlight_size: Vector2 = Vector2(4, 4)


func _ready():
	if no_children():
		return

	farm_grid.setup_collider()

	TPLG.dialogue.add_dialogue_script("highlight_tiller", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil", self)
	TPLG.dialogue.add_dialogue_script("return_to_game", self)
	TPLG.dialogue.add_dialogue_script("plant_seeds_tut", self)

	TPLG.current_farm_grids = [farm_grid]

	jkjz._move_event({"ping": "0", "x": player_entry.position.x + 16, "y": player_entry.position.y})

	if (
		! "tutorialFarmingTilling" in TPLG.ui.mission_list.get_current_mission_keys()
		&& ! "tutorialFarmingTilling" in TPLG.ui.mission_list.get_completed_mission_keys()
	):
		start_mission("tutorialFarmingTilling")

	timer.one_shot = true
	timer.wait_time = 3
	timer.connect("timeout", self, "_deliver_intro_dialogue")
	timer.start()

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(Vector2(x, y))

	_synthesize_inventory()


func _exit_tree():
	if no_children():
		return

	TPLG.dialogue.remove_dialogue_script("highlight_tiller")
	TPLG.dialogue.remove_dialogue_script("highlight_soil")
	TPLG.dialogue.remove_dialogue_script("return_to_game")
	TPLG.dialogue.remove_dialogue_script("plant_seeds_tut")


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


func highlight_tiller():
	# determine which inventory slot has the tiller
	# - as the user can't move items currently, it'll always be in the 0 slot for now
	var tiller_idx = 0
	var tiller = TPLG.inventory.tiles[tiller_idx]

	if ! tiller.is_connected("select_slot", self, "_has_highlighted"):
		tiller.point_at_tile()
		tiller.connect("equip_item", self, "_has_highlighted", [tiller_idx])


func _has_highlighted(slot: int):
	var tiller = TPLG.inventory.tiles[slot]

	tiller.stop_pointing()
	tiller.disconnect("equip_item", self, "_has_highlighted")

	TPLG.dialogue.start("JKJZ/Tutorials/TillTutorial", "playerHasSelectedTiller")


func highlight_soil():
	if ! MatchEvent.is_connected("farming", self, "_handle_farming_event"):
		MatchEvent.connect("farming", self, "_handle_farming_event")

		tile_highlighter.highlight(
			farm_grid.position / 16, farm_grid.position / 16 + tiles_to_highlight_size
		)


func _handle_farming_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != Player.user_id:
		return

	var args = JSON.parse(msg).result

	if int(args.type) == FarmEvent.TILL:
		var tile_pos = Vector2(args.x, args.y)

		tile_highlighter.unhighlight_tile(farm_grid.position / 16 + tile_pos)

		if tile_pos in tiles_to_highlight:
			tiles_to_highlight.erase(tile_pos)

		if tiles_to_highlight.size() == 0:
			if "tutorialFarmingTilling" in TPLG.ui.mission_list.get_current_mission_keys():
				finish_mission("tutorialFarmingTilling")

			TPLG.dialogue.start("JKJZ/Tutorials/TillTutorial", "playerHasTilledSoil")


func return_to_game():
	TPLG.base_change_scene("res://RootScenes/%s.tscn" % TPLG.last_scene)


func plant_seeds_tut():
	TPLG.base_change_scene("res://RootScenes/Tutorials/Farming/PlantingTutorial.tscn")
