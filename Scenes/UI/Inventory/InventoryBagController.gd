extends Node2D

var equiptable_item_scenes = {
	InventoryItems.TILLER: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Tiller.tscn"),
	InventoryItems.PAIL: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Pail.tscn"),
	InventoryItems.PICKAXE: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Pickaxe.tscn"),
	InventoryItems.SCYTHE: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Scythe.tscn"),
	InventoryItems.AXE: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Axe.tscn"),
	InventoryItems.STONE:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Drops/Stone.tscn"),
	InventoryItems.FERN: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Drops/Fern.tscn"),
	InventoryItems.WOOD: ResourceLoader.load("res://Scenes/Items/EquiptableItems/Drops/Wood.tscn"),
	InventoryItems.BLUEPRINT__WOOD_PATH:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Blueprints/WoodPath.tscn"),
	InventoryItems.CRAFTED__WOOD_PATH:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/CraftedItems/WoodPath.tscn"),
	InventoryItems.BLUEPRINT__STONE_PATH:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Blueprints/StonePath.tscn"),
	InventoryItems.CRAFTED__STONE_PATH:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/CraftedItems/StonePath.tscn"),
	InventoryItems.BLUEPRINT__LAMP:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Blueprints/Lamp.tscn"),
	InventoryItems.CRAFTED__LAMP:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/CraftedItems/Lamp.tscn"),
	InventoryItems.CABBAGE_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/CabbageSeedPack.tscn"),
	InventoryItems.CABBAGE:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Cabbage.tscn"),
	InventoryItems.BEET_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/BeetSeedPack.tscn"),
	InventoryItems.BEET:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Beet.tscn"),
	InventoryItems.DRAGON_FRUIT_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/DragonFruitSeedPack.tscn"),
	InventoryItems.DRAGON_FRUIT:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/DragonFruit.tscn"),
	InventoryItems.EGGPLANT_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/EggplantSeedPack.tscn"),
	InventoryItems.EGGPLANT:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Eggplant.tscn"),
	InventoryItems.POTATO_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/PotatoSeedPack.tscn"),
	InventoryItems.POTATO:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Potato.tscn"),
	InventoryItems.ODD_FRUIT_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/OddFruitSeedPack.tscn"),
	InventoryItems.ODD_FRUIT:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/OddFruit.tscn"),
	InventoryItems.TOMATO_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/TomatoSeedPack.tscn"),
	InventoryItems.TOMATO:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Tomato.tscn"),
	InventoryItems.TURNIP_SEEDS:
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/Seeds/TurnipSeedPack.tscn"),
	InventoryItems.TURNIP:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Turnip.tscn"),
}

var data: Dictionary
var equippable_items: Dictionary = {}

onready var inventory = get_parent()


func get_at_slot(slot: int):
	var item

	for _item in data.bag:
		if _item.bagPosition == slot:
			item = _item

	return null if item == null else item


func get_item_action(slot: int):
	return equippable_items[slot]


func _ready():
	MatchEvent.connect("data_reset", self, "reload_and_redraw_data")
	yield(load_data(), "completed")
	draw_items_from_data()


func _exit_tree():
	MatchEvent.disconnect("data_reset", self, "reload_and_redraw_data")


func load_data():
	data = yield(SaveData.load("inventoryBag"), "completed")


func reload_and_redraw_data(_args, _presence):
	yield(load_data(), "completed")
	redraw_bag()


func redraw_bag():
	for tile in get_parent().tiles:
		tile.update_quantity(0)

	for node in get_children():
		node.queue_free()

	equippable_items.clear()
	draw_items_from_data()


func draw_items_from_data():
	for item_data in data.bag:
		add_item_scene_or_update_quantity(item_data)


func add_item_scene_or_update_quantity(item_data: Dictionary):
	if item_data.bagPosition >= inventory.columns:
		print_debug("TODO: Need to implement multi row inventory")
		return

	if ! equippable_items.has(int(item_data.bagPosition)):
		var item_int = InventoryItems.get_int_from_hash(item_data.itemTypeId)

		var item_scene = equiptable_item_scenes.get(item_int)
		var item_node = item_scene.instance()

		equippable_items[int(item_data.bagPosition)] = item_node
		item_node.position = inventory.bag_slot_to_position(item_data.bagPosition)

		add_child(item_node)

		item_node.set_collision_mask_on_interaction_area(0)

		if item_node.has_method("ready_for_inventory"):
			item_node.ready_for_inventory()

		if inventory.equipped_item == null:
			inventory.equipped_item = item_node

	inventory.tiles[item_data.bagPosition].update_quantity(item_data.quantity)


func move_item(_old_bag_position: int, _bag_position: int):
	# probably should call server && perform local?
	# we weren't actually calling this early iirc
	pass


var to_add: Array = []

var is_adding: bool = false


func _physics_process(_delta):
	if to_add.size() > 0 && ! is_adding:
		is_adding = true
		var item = to_add.pop_back()
		yield(_add_item(item.type, item.context), "completed")
		is_adding = false


func add_item(type: int, context: String = ""):
	to_add.append({"type": type, "context": context})


func _add_item(type: int, context: String = ""):
	var item_data = {
		"item": InventoryItems.get_hash_from_int(type),
		"quantity": 1,
		"avatar": SaveData.current_avatar_key,
	}

	if context != "":
		item_data["context"] = context

	var add_item_call = yield(
		SessionManager.rpc_async("inventory.add_item", JSON.print(item_data)), "completed"
	)

	if add_item_call.payload != "false":
		add_item_locally(type)


func remove_item_locally(item_type, quantity: int = 1):
	var item

	for _item in data.bag:
		if InventoryItems.get_int_from_hash(_item.itemTypeId) == item_type:
			item = _item

	if item == null:
		return

	if item.quantity > quantity:
		item.quantity -= quantity
		inventory.tiles[item.bagPosition].update_quantity(item.quantity)
	elif item.quantity == quantity:
		inventory.tiles[item.bagPosition].update_quantity(0)
		equippable_items[int(item.bagPosition)].queue_free()
		equippable_items[int(item.bagPosition)] = null


func add_item_locally(item_type: int):
	var bag_position: int = get_first_empty_bag_position()

	var has_item

	for item in data.bag:
		if InventoryItems.get_int_from_hash(item.itemTypeId) == item_type:
			has_item = item
			bag_position = item.bagPosition

	if bag_position >= inventory.columns:
		print_debug("TODO: Need to implement multi row inventory")
		return

	var quantity = 1

	if has_item != null:
		has_item.quantity += 1
		quantity = has_item.quantity

	var item = {
		"bagPosition": bag_position,
		"itemTypeId": InventoryItems.get_hash_from_int(item_type),
		"quantity": quantity
	}

	if has_item == null:
		data.bag.append(item)

	add_item_scene_or_update_quantity(item)


func has_item(type):
	if type is String:
		type = InventoryItems.get_int_from_hash(type)

	var item

	for _item in data.bag:
		if InventoryItems.get_int_from_hash(_item.itemTypeId) == type:
			item = _item

	return item != null


func has_item_at(slot: int):
	var item

	for _item in data.bag:
		if _item.bagPosition == slot:
			item = _item

	return item != null


func has_empty_slot():
	var slot: int = -1

	for i in range(inventory.columns):
		if has_item_at(i) == false:
			return i

	return slot


func get_first_empty_bag_position():
	for i in range(inventory.columns):
		if get_at_slot(i) == null:
			return i

	return -1
