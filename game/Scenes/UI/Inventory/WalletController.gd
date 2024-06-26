extends Node2D

var tiles = []

const width = 2
const height = 1
const bag_size = width * height
const box_size = 16

var current_corpus = SessionManager.get_corpus_coin()
var current_commco = SessionManager.get_community_coin()

var inventory_tile_scene = ResourceLoader.load("res://Scenes/UI/Inventory/InventoryTile.tscn")

var coin_scene_paths = [
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/CorpusCoin.tscn", ""),
	ResourceLoader.load("res://Scenes/Items/EquiptableItems/CommunityCoin.tscn", "")
]

onready var surplus_box = $SurplusBox


func bag_slot_to_position(id: int):
	var x = id % width
	var y = id / width

	var position = Vector2(x * box_size, y * box_size)

	return position


func _ready():
	TPLG.set_wallet(self)
	setup_grid()
	RealmEvent.connect("wallet_update", self, "on_day_break")
	yield(sync_with_wallet(), "completed")


func _exit_tree():
	RealmEvent.disconnect("wallet_update", self, "on_day_break")


func on_day_break(_args, _presence):
	yield(sync_with_wallet(), "completed")


func setup_grid():
	for row in range(height):
		for col in range(width):
			var position = row * width + col

			var tile = inventory_tile_scene.instance()
			tile.rect_position = bag_slot_to_position(position)
			tiles.insert(position, tile)

			add_child(tile)

			var item_scene = coin_scene_paths[col]
			var item_node = item_scene.instance()
			item_node.position = bag_slot_to_position(position)

			add_child(item_node)


func sync_with_wallet():
	yield(SessionManager.load_api_account(), "completed")

	for _row in range(height):
		for col in range(width):
			tiles[col].update_quantity(
				(
					SessionManager.get_corpus_coin()
					if col == 0
					else SessionManager.get_community_coin()
				)
			)

	if current_commco > -1 && current_commco < SessionManager.get_community_coin():
		var diff = SessionManager.get_community_coin() - current_commco
		surplus_box.add_community_coin(diff, current_corpus == 100)

	if current_corpus > -1 && current_corpus < SessionManager.get_corpus_coin():
		var diff = SessionManager.get_corpus_coin() - current_corpus
		surplus_box.add_corpus_coin(diff)

	current_corpus = SessionManager.get_corpus_coin()
	current_commco = SessionManager.get_community_coin()

# TODO: The below also need to update local data store

# func deduct_corpus_coin(amount: int):
# 	tiles[0].update_quantity(SessionManager.get_corpus_coin() - amount)

# func add_corpus_coin(amount: int):
# 	tiles[0].update_quantity(SessionManager.get_corpus_coin() + amount)

# func deduct_community_coin(amount: int):
# 	tiles[0].update_quantity(SessionManager.get_community_coin() - amount)

# func add_community_coin(amount: int):
# 	tiles[0].update_quantity(SessionManager.get_community_coin() + amount)
