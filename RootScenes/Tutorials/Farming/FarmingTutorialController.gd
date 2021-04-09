extends "res://RootScenes/RootController.gd"

onready var player_entry = find_node("PlayerEntry")
onready var jkjz = find_node("JKJZ")
onready var timer: Timer = find_node("Timer")
onready var farm_grid = find_node("FarmGrid")
onready var tiles_to_highlight: Array = []

var tiles_to_highlight_size: Vector2
var mission_key: String
var item_idx: int
var dialogue_dict: String
var has_highlighted_dialogue_idx: String
var has_completed_farm_task_idx: String
var next_tut_scene: String
var farm_event_idx: int


func _ready():
	if no_children():
		return

	_on_ready()


func _on_ready():
	if no_children():
		return

	farm_grid.setup_collider()

	TPLG.dialogue.add_dialogue_script("highlight_item", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil", self)
	TPLG.dialogue.add_dialogue_script("return_to_game", self)
	TPLG.dialogue.add_dialogue_script("next_tut", self)

	TPLG.current_farm_grids = [farm_grid]

	_synthesize_inventory()

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(Vector2(x, y))

	if (
		! mission_key in TPLG.ui.mission_list.get_current_mission_keys()
		&& ! mission_key in TPLG.ui.mission_list.get_completed_mission_keys()
	):
		start_mission(mission_key)


func _exit_tree():
	if no_children():
		return

	TPLG.dialogue.remove_dialogue_script("highlight_item")
	TPLG.dialogue.remove_dialogue_script("highlight_soil")
	TPLG.dialogue.remove_dialogue_script("return_to_game")
	TPLG.dialogue.remove_dialogue_script("next_tut")


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


func highlight_item():
	var item = TPLG.inventory.tiles[item_idx]

	if ! item.is_connected("select_slot", self, "_has_highlighted"):
		item.point_at_tile()
		item.connect("equip_item", self, "_has_highlighted", [item_idx])


func _has_highlighted(slot: int):
	var item = TPLG.inventory.tiles[slot]

	item.stop_pointing()
	item.disconnect("equip_item", self, "_has_highlighted")

	TPLG.dialogue.start(dialogue_dict, has_highlighted_dialogue_idx)


func highlight_soil():
	if ! MatchEvent.is_connected("farming", self, "_handle_farming_event"):
		MatchEvent.connect("farming", self, "_handle_farming_event")

		tile_highlighter.highlight(
			farm_grid.position / 16, farm_grid.position / 16 + tiles_to_highlight_size
		)


func _handle_farming_event(msg, presence):
	if msg == null || presence.user_id != Player.user_id:
		return

	var args = JSON.parse(msg).result

	if int(args.type) == farm_event_idx:
		var tile_pos = Vector2(args.x, args.y)

		tile_highlighter.unhighlight_tile(farm_grid.position / 16 + tile_pos)

		if tile_pos in tiles_to_highlight:
			tiles_to_highlight.erase(tile_pos)

		if tiles_to_highlight.size() == 0:
			if mission_key in TPLG.ui.mission_list.get_current_mission_keys():
				finish_mission(mission_key)

			TPLG.dialogue.start(dialogue_dict, has_completed_farm_task_idx)
			MatchEvent.disconnect("farming", self, "_handle_farming_event")


func return_to_game():
	TPLG.goto_last_scene()


func next_tut():
	TPLG.base_change_scene(next_tut_scene)
