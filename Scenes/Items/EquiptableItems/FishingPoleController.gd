extends "res://Scenes/Items/ItemController.gd"


func primary_action():
	if Player.is_over_water_source:
		MatchEvent.fishing_lure()
