extends "res://RootScenes/RootController.gd"

onready var player_entry = find_node("PlayerEntry")
onready var jkjz = find_node("JKJZ")
onready var timer: Timer = find_node("Timer")
onready var farm_grid = find_node("FarmGrid")


func _ready():
	if no_children():
		return

	TPLG.dialogue.add_dialogue_script("highlight_seed_packs", self)

	_synthesize_inventory()

	farm_grid.data = {
		"forageItems": [],
		"plants": [],
		"craftedItems": [],
		"groundTiles":
		{"0": {"0": "tilled"}, "1": {"0": "tilled"}, "2": {"0": "tilled"}, "3": {"0": "tilled"}}
	}

	farm_grid.call_deferred("draw_things_from_data")
	farm_grid.setup_collider()

	TPLG.current_farm_grids = [farm_grid]

	TPLG.dialogue.start("JKJZ/Tutorials/SeedTutorial", "seedTutorialBegin")


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("highlight_seed_packs")


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


func highlight_seed_packs():
	var seed_idx = 6
	var seed_pack = TPLG.inventory.tiles[seed_idx]

	if ! seed_pack.is_connected("equip_item", self, "_has_highlighted"):
		seed_pack.point_at_tile()
		seed_pack.connect("equip_item", self, "_has_highlighted", [seed_idx])


func _has_highlighted(slot: int):
	var seed_pack = TPLG.inventory.tiles[slot]

	seed_pack.stop_pointing()
	seed_pack.disconnect("equip_item", self, "_has_highlighted")

	TPLG.dialogue.start("JKJZ/Tutorials/SeedTutorial", "playerHasSelectedSeeds")
