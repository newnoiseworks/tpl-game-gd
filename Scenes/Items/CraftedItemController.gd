extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	place_crafted_item_on_farm_grid()


func secondary_action():
	remove_crafted_item_on_farm_grid()
