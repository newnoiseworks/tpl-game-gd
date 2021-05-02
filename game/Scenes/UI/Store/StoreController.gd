extends Container

var item_scene = ResourceLoader.load("res://Scenes/UI/Store/StoreItem.tscn")
var catalog_items = {}

onready var items_for_sale_container: VBoxContainer = find_node("SellList")
onready var items_for_purchase_container: VBoxContainer = find_node("PurchaseList")


func _ready():
	TPLG.set_store(self)
	clear_store()

	var response = yield(SessionManager.rpc_async("pos.get_prices"), "completed")

	catalog_items = JSON.parse(response.payload).result


func populate_store(allowed_purchase_items: Array = [], allowed_sale_items: Array = []):
	clear_store()

	if allowed_purchase_items.size() > 0:
		for key in catalog_items.keys():
			var item = catalog_items[key]

			if allowed_purchase_items.has(InventoryItems.get_int_from_hash(key)):
				var item_obj = item_scene.instance()

				item_obj.is_combo_price = item.has("comboPrice") && item["comboPrice"]
				item_obj.item_key_name = String(item["key"])
				item_obj.price_definitions = item["price"]
				item_obj.type = key

				items_for_purchase_container.add_child(item_obj)

	if allowed_sale_items.size() > 0:
		for key in catalog_items.keys():
			var item = catalog_items[key]

			if allowed_sale_items.has(InventoryItems.get_int_from_hash(key)):
				var item_obj = item_scene.instance()

				item_obj.is_combo_price = item.has("comboPrice") && item["comboPrice"]
				item_obj.item_key_name = String(item["key"])
				item_obj.price_definitions = item["sale"]
				item_obj.is_sale = true
				item_obj.type = key

				items_for_sale_container.add_child(item_obj)

	show()


func on_close_button_up():
	hide()


func clear_store():
	for kontrol in items_for_sale_container.get_children():
		kontrol.queue_free()

	for kontrol in items_for_purchase_container.get_children():
		kontrol.queue_free()
