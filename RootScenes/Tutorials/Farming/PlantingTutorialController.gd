extends "res://RootScenes/RootController.gd"

onready var player_entry = find_node("PlayerEntry")
onready var jkjz = find_node("JKJZ")
onready var timer: Timer = find_node("Timer")
onready var farm_grid = find_node("FarmGrid")


func _ready():
	if no_children():
		return

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
