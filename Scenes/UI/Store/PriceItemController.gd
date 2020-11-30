extends Button

var item_key_name: String
var purchase_key_name: String
var quantity: int
var is_sale: bool
var type: String

onready var picture: Sprite = find_node("Sprite")


func _ready():
	var path = I18n.get_line("InventoryItems", item_key_name, "image")

	picture.texture = ResourceLoader.load("res://%s" % path)
	text = String(quantity)


func on_button_up():
	if (
		! is_sale
		&& TPLG.inventory.bag.has_empty_slot() == -1
		&& TPLG.inventory.bag.has_item(type) == false
	):
		# UIController.ShowToast("Inventory Full!");
		print_debug("TODO: Need to implement multi row inventory, skipping purchase")
		return

	disabled = true

	var response: NakamaAPI.ApiRpc = yield(
		SessionManager.rpc_async(
			"pos.sell_item" if is_sale else "pos.purchase_item",
			JSON.print(
				{
					"item": purchase_key_name,
					"currency": item_key_name,
					"avatar": SaveData.current_avatar_key
				}
			)
		),
		"completed"
	)

	if response.payload:
		if is_sale:
			TPLG.inventory.bag.remove_item_locally(
				InventoryItems.get_int_from_name(purchase_key_name)
			)
		else:
			TPLG.inventory.bag.add_item_locally(InventoryItems.get_int_from_name(purchase_key_name))

		# TODO: The below *should* just update the items in the inventory locally!
		yield(TPLG.wallet.sync_with_wallet(), "completed")
	elif response.payload == "false":
		print_debug("call failed.")

	disabled = false
