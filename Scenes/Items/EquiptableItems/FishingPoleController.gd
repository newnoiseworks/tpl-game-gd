extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	print("lets fish")

	MatchEvent.fishing_lure()
