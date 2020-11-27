extends Container

var item_scene = ResourceLoader.load("res://Scenes/UI/Store/StoreItem.tscn")
var items_for_sale_container: VBoxContainer = find_node("SellList")
var items_for_purchase_container: VBoxContainer = find_node("PurchaseList")
var catalog_items = {}


func _ready():
	TPLG.set_store(self)
	clear_store()

	catalog_items = JSON.parse(
		yield(SessionManager.rpc_async("pos.get_prices"), "completed").payload
	).result


func populate_store(allowed_purchase_items: Array = [], allowed_sale_items: Array = []):
	clear_store()

	if allowed_purchase_items.size() > 0:
		for key in catalog_items.keys():
			var item = catalog_items[key]

			if allowed_purchase_items.has(key):
				var item_obj = item_scene.instance()

				item_obj.is_combo_price = item.has("comboPrice") && item["comboPrice"]
				item_obj.item_key_name = String(item["key"])
				item_obj.price_definitions = item["price"]
				item_obj.type = key

				items_for_purchase_container.add_child(item_obj)

	if allowed_sale_items.size() > 0:
		for key in catalog_items.keys():
			var item = catalog_items[key]

			if allowed_sale_items.has(key):
				var item_obj = item_scene.instance()

				item_obj.is_combo_price = item.has("comboPrice") && item["comboPrice"]
				item_obj.item_key_name = String(item["key"])
				item_obj.price_definitions = item["sale"]
				item_obj.is_sale = true
				item_obj.type = key

				items_for_purchase_container.add_child(item_obj)

	show()


func on_close_button_up():
	hide()


func clear_store():
	for kontrol in items_for_sale_container.get_children():
		kontrol.queue_free()

	for kontrol in items_for_purchase_container.get_children():
		kontrol.queue_free()
