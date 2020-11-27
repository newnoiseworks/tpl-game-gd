extends Button

var item_key_name: String
var purchase_key_name: String
var quantity: int
var is_sale: bool
var type: Node2D

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
			(
				"{{ \"item\": \"%s\", \"currency\": \"%s\", \"avatar\": \"%s\" }}"
				% [purchase_key_name, item_key_name, SaveData.current_avatar_key]
			)
		),
		"completed"
	)

	if response.payload:
		# TODO: The below *should* just update the items in the inventory locally!
		yield(TPLG.Inventory.bag.reload_and_redraw_data({}), "completed")
		# await WalletController.instance.SyncWithWallet();
	elif response.payload == "false":
		print_debug("call failed.")

	disabled = false
