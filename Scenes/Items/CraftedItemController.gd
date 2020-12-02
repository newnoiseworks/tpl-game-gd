extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	print("are we placing yet")
	place_crafted_item_on_farm_grid()


func secondary_action():
	print("it should be happening")
	remove_crafted_item_on_farm_grid()
