extends "res://Scenes/Items/ItemController.gd"

var data

var blueprint_to_items: Dictionary = {
	InventoryItems.BLUEPRINT__STONE_PATH: InventoryItems.CRAFTED__STONE_PATH,
	InventoryItems.BLUEPRINT__WOOD_PATH: InventoryItems.CRAFTED__WOOD_PATH,
	InventoryItems.BLUEPRINT__LAMP: InventoryItems.CRAFTED__LAMP,
	InventoryItems.BLUEPRINT__LAMP2: InventoryItems.CRAFTED__LAMP2,
	InventoryItems.BLUEPRINT__LAMP3: InventoryItems.CRAFTED__LAMP3,
	InventoryItems.BLUEPRINT__LAMP4: InventoryItems.CRAFTED__LAMP4,
	InventoryItems.BLUEPRINT__LAMP5: InventoryItems.CRAFTED__LAMP5,
	InventoryItems.BLUEPRINT__STANDING_GNOME: InventoryItems.CRAFTED__STANDING_GNOME,
	InventoryItems.BLUEPRINT__STANDING_GNOME2: InventoryItems.CRAFTED__STANDING_GNOME2,
	InventoryItems.BLUEPRINT__SITTING_GNOME: InventoryItems.CRAFTED__SITTING_GNOME,
	InventoryItems.BLUEPRINT__SITTING_GNOME2: InventoryItems.CRAFTED__SITTING_GNOME2,
	InventoryItems.BLUEPRINT__STONE_PILE: InventoryItems.CRAFTED__STONE_PILE,
	InventoryItems.BLUEPRINT__MODERN_STATUE: InventoryItems.CRAFTED__MODERN_STATUE,
	InventoryItems.BLUEPRINT__SCARECROW: InventoryItems.CRAFTED__SCARECROW,
	InventoryItems.BLUEPRINT__SPOOK: InventoryItems.CRAFTED__SPOOK,
	InventoryItems.BLUEPRINT__SPOOK2: InventoryItems.CRAFTED__SPOOK2,
	InventoryItems.BLUEPRINT__FLAMINGO: InventoryItems.CRAFTED__FLAMINGO
}


func _ready():
	TPLG.set_reatomizer(self)
	load_data()


func load_data():
	data = yield(SaveData.load("reatomizer"), "completed")

	if data.blueprints == null || data.blueprints.size() == 0:
		data.blueprints = []


func interact():
	setup_store()


func setup_store():
	if data.blueprints.size() == 0:
		TPLG.ui.show_toast("Get some blueprints from Violine in town!")
		return

	var craftable_items = []

	for blueprint in data.blueprints:
		if blueprint is Dictionary && blueprint.has("blueprint"):
			craftable_items.append(
				blueprint_to_items[InventoryItems.get_int_from_hash(blueprint.blueprint)]
			)
		elif blueprint is String:
			craftable_items.append(blueprint_to_items[InventoryItems.get_int_from_hash(blueprint)])

	TPLG.store.populate_store(craftable_items)


func add_blueprint(type):
	var item_data = {
		"blueprint": InventoryItems.get_hash_from_int(type), "avatar": SaveData.current_avatar_key
	}

	var add_blueprint_call = yield(
		SessionManager.rpc_async("reatomizer.add_blueprint", JSON.print(item_data)), "completed"
	)

	var valid_call = add_blueprint_call.payload != "false"

	if valid_call:
		TPLG.inventory.bag.remove_item_locally(type)
		load_data()


func has_blueprint(type):
	for blueprint in data.blueprints:
		if blueprint == InventoryItems.get_hash_from_int(type):
			return true

	return false
