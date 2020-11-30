extends "res://Scenes/Items/ItemController.gd"

var data

var blueprint_to_items: Dictionary = {
	InventoryItems.BLUEPRINT__STONE_PATH: InventoryItems.CRAFTED__STONE_PATH,
	InventoryItems.BLUEPRINT__WOOD_PATH: InventoryItems.CRAFTED__WOOD_PATH,
	InventoryItems.BLUEPRINT__LAMP: InventoryItems.CRAFTED__LAMP
}


func _ready():
	TPLG.set_reatomizer(self)
	data = SaveData.load("reatomizer")


func interact():
	setup_store()


func setup_store():
	if data.blueprints.size() == 0:
		TPLG.ui.show_toast("Get some blueprints from Violine in town!")

	var craftable_items = []

	for blueprint in data.blueprints:
		craftable_items.append(blueprint_to_items[blueprint])

	TPLG.store.populate_store(craftable_items)


func add_blueprint(type):
	var item_data = {
		"blueprint": InventoryItems.get_hash_from_int(type), "avatar": SaveData.current_avatar_key
	}

	var add_blueprint_call = yield(
		SessionManager.rpc_async("reatomizer.add_blueprint", JSON.print(item_data)), "completed"
	)

	var valid_call = add_blueprint_call.payload != "false"

	if add_blueprint_call.payload != "false":
		data.blueprints.append(item_data)

	if valid_call:
		yield(TPLG.inventory.bag.reload_and_redraw_data(), "completed")
