extends Node2D

# var InventoryController instance = null;

var equipped_item: Node2D
var bag: Node2D
var tiles: Array
var equipped_item_highlight: Sprite

const columns: int = 12
const rows: int = 1
const bag_size: int = columns * rows
const box_size: int = 16

var inventory_tile_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/Inventory/InventoryTile.tscn"
)
var inventory_bag_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/Inventory/InventoryBag.tscn"
)
var equipped_item_highlight_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/Inventory/EquippedItemHighlight.tscn"
)

var current_equipped_slot: int = 0


func bag_slot_to_position(id: int) -> Vector2:
	var x = id % columns
	var y = id / columns

	return Vector2(x * box_size, y * box_size)


func _ready():
	TPLG.set_inventory(self)

	setup_grid()

	position.x = columns * -20  # feels awful magical

	bag = inventory_bag_scene.instance()
	bag.position = bag_slot_to_position(0)
	add_child(bag)

	equipped_item_highlight = equipped_item_highlight_scene.instance()
	add_child(equipped_item_highlight)
	equipped_item_highlight.position = bag_slot_to_position(current_equipped_slot) + Vector2(8, 8)


func _exit_tree():
	for tile in tiles:
		tile.disconnect("select_slot", self, "on_select_slot")
		tile.disconnect("equip_item", self, "on_equip_item")


func shift_equipped_item(up: bool = true):
	var next_slot: int = current_equipped_slot + 1 if up else current_equipped_slot - 1

	if next_slot >= columns:
		next_slot = 0
	elif next_slot < 1:
		next_slot = columns - 1

	on_equip_item(next_slot)


func setup_grid():
	tiles = []

	for row in range(rows):
		for col in range(columns):
			var position = row * columns + col
			var tile = inventory_tile_scene.instance()
			tile.rect_position = bag_slot_to_position(position)
			tiles.insert(position, tile)

			add_child(tile)
			var binds = []
			binds.insert(0, position)

			tile.connect("select_slot", self, "on_select_slot", binds)
			tile.connect("equip_item", self, "on_equip_item", binds)


func on_equip_item(slot: int):
	current_equipped_slot = slot
	equipped_item_highlight.position = bag_slot_to_position(slot) + Vector2(8, 8)

	if ! bag.has_item_at(slot):
		equipped_item = null
		return

	equipped_item = bag.get_item_action(slot)


func on_select_slot(slot: int):
	bag.move_item(current_equipped_slot, slot)
	on_equip_item(slot)
