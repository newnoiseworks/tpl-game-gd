extends "res://Scenes/Items/ItemController.gd"

export var inventory_item_type: String

# TODO: See below comments on making this separate classes
export var mission_key: String
export var mission_context_meta: String

var forage_item_data
var farm_owner_id
var farm_owner_avatar
var farm_owner_collection

onready var type = InventoryItems.get_int_from_name(inventory_item_type)


func _ready():
	tween.connect("tween_completed", self, "on_tween_complete")


func on_body_enter(body):
	if body != Player:
		return

	if TPLG.inventory.bag.has_empty_slot() == -1 && TPLG.inventory.bag.has_item(type) == false:
		TPLG.ui.show_toast("Inventory Full!")
		print("TODO: Need to implement multi row inventory")
		return

	var destination = Player.position - get_parent().position

	tween.interpolate_property(
		self, "position", position, destination, 0.35, Tween.TRANS_QUINT, Tween.EASE_IN
	)

	tween.start()

	var context = {}

	# TODO: Break this out into three classes; DropItem as a parent, then ForageDropItem and MissionDropItem as children  
	if forage_item_data != null:
		context = {
			"farm_owner_id": farm_owner_id,
			"farm_owner_avatar": farm_owner_avatar,
			"farm_owner_collection": farm_owner_collection,
			"x": forage_item_data.x,
			"y": forage_item_data.y,
			"forage_item_type": forage_item_data.type
		}
	elif mission_key != null:
		context = {"mission_key": mission_key, "meta": mission_context_meta}

	TPLG.inventory.bag.add_item(type, JSON.print(context))


func on_tween_complete(_arg1, _arg2):
	queue_free()
