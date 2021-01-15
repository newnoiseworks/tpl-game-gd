extends "res://RootScenes/DungeonController.gd"


func _ready():
	TPLG.ui.hide_loading_dialog()


func lake_body_enter(body):
	if body == MoveTarget:
		Player.is_over_water_source = true


func lake_body_exit(body):
	if body == MoveTarget:
		Player.is_over_water_source = false
