extends "res://Scenes/Items/ItemController.gd"

export var blueprint_type: String


func primary_action():
	var type = InventoryItems.get_int_from_name("Blueprint_%s" % blueprint_type)
	yield(TPLG.reatomizer.add_blueprint(type), "completed")
