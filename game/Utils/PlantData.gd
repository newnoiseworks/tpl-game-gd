extends Node

const plant_item_type_map = {
	"Cabbage": InventoryItems.CABBAGE,
	"Beet": InventoryItems.BEET,
	"DragonFruit": InventoryItems.DRAGON_FRUIT,
	"Eggplant": InventoryItems.EGGPLANT,
	"Potato": InventoryItems.POTATO,
	"OddFruit": InventoryItems.ODD_FRUIT,
	"Tomato": InventoryItems.TOMATO,
	"Turnip": InventoryItems.TURNIP,
}

const seed_item_type_map = {
	"Cabbage": InventoryItems.CABBAGE_SEEDS,
	"Beet": InventoryItems.BEET_SEEDS,
	"DragonFruit": InventoryItems.DRAGON_FRUIT_SEEDS,
	"Eggplant": InventoryItems.EGGPLANT_SEEDS,
	"Potato": InventoryItems.POTATO_SEEDS,
	"OddFruit": InventoryItems.ODD_FRUIT_SEEDS,
	"Tomato": InventoryItems.TOMATO_SEEDS,
	"Turnip": InventoryItems.TURNIP_SEEDS,
}

var item_type_to_plant_scene_map = {
	InventoryItems.get_hash_from_int(InventoryItems.CABBAGE):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Cabbage.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.BEET):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Beet.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.DRAGON_FRUIT):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/DragonFruit.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.EGGPLANT):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Eggplant.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.POTATO):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Potato.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.ODD_FRUIT):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/OddFruit.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.TOMATO):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Tomato.tscn"),
	InventoryItems.get_hash_from_int(InventoryItems.TURNIP):
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/Plants/Turnip.tscn"),
}

var seed_to_plant_hash_map = {
	InventoryItems.get_hash_from_int(InventoryItems.CABBAGE_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.CABBAGE),
	InventoryItems.get_hash_from_int(InventoryItems.BEET_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.BEET),
	InventoryItems.get_hash_from_int(InventoryItems.DRAGON_FRUIT_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.DRAGON_FRUIT),
	InventoryItems.get_hash_from_int(InventoryItems.EGGPLANT_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.EGGPLANT),
	InventoryItems.get_hash_from_int(InventoryItems.POTATO_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.POTATO),
	InventoryItems.get_hash_from_int(InventoryItems.ODD_FRUIT_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.ODD_FRUIT),
	InventoryItems.get_hash_from_int(InventoryItems.TOMATO_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.TOMATO),
	InventoryItems.get_hash_from_int(InventoryItems.TURNIP_SEEDS):
	InventoryItems.get_hash_from_int(InventoryItems.TURNIP)
}
