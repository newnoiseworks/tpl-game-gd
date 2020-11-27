extends Control

var item_key_name: String
var price_definitions: PoolStringArray
var is_sale: bool = false
var is_combo_price: bool
var type

var price_item_scene = ResourceLoader.load("res://Scenes/UI/Store/PriceItem.tscn")
onready var title_label = find_node("Title")
onready var description_label = find_node("Description")
onready var picture = find_node("Picture")
onready var price_container = find_node("PriceBox")


func _ready():
	title_label.text = I18n.get_line("InventoryItems", item_key_name, "label")
	description_label.text = I18n.get_line("InventoryItems", item_key_name, "description")
	picture.texture = ResourceLoader.load(
		"res://%s" % I18n.get_line("InventoryItems", item_key_name, "image")
	)

	setup_price_items()


func setup_price_items():
	# if is_combo_price:

	# else:
	for price_json in price_definitions:
		var price = JSON.parse("{" + price_json + "}").parse

		var price_item = price_item_scene.instance()

		price_item.item_key_name = price["itemKey"]
		price_item.purchase_key_name = item_key_name
		price_item.quantity = int(price["quantity"])
		price_item.is_sale = is_sale
		price_item.type = type

		price_container.add_child(price_item)
