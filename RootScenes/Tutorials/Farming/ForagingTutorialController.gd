extends "res://RootScenes/Tutorials/Farming/FarmingTutorialController.gd"

var farm_grid_2
var farm_grid_3

var tile_offset: Vector2 = Vector2(1, 1)


func _init():
	mission_key = "tutorialForaging"
	tiles_to_highlight_size = Vector2(1, 4)
	dialogue_dict = "JKJZ/Tutorials/ForagingTutorial"
	next_tut_scene = "res://RootScenes/Tutorials/Farming/HarvestingTutorial.tscn"
	farm_event_idx = FarmEvent.FORAGE
	block_mission_finish = true


func _on_ready():
	._on_ready()

	farm_grid_2 = find_node("FarmGrid2")
	farm_grid_3 = find_node("FarmGrid3")
	farm_grid_2.setup_collider()
	farm_grid_3.setup_collider()

	TPLG.current_farm_grids.append(farm_grid_2)
	TPLG.current_farm_grids.append(farm_grid_3)

	_setup_farm_grid_one()
	_setup_farm_grid_two()
	_setup_farm_grid_three()

	TPLG.dialogue.start(dialogue_dict, "foragingTutorialBegin")

	TPLG.dialogue.add_dialogue_script("highlight_pickaxe", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil_with_stones", self)
	TPLG.dialogue.add_dialogue_script("highlight_scythe", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil_with_weeds", self)
	TPLG.dialogue.add_dialogue_script("highlight_axe", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil_with_trees", self)


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("highlight_pickaxe")
	TPLG.dialogue.remove_dialogue_script("highlight_soil_with_stones")
	TPLG.dialogue.remove_dialogue_script("highlight_scythe")
	TPLG.dialogue.remove_dialogue_script("highlight_soil_with_weeds")
	TPLG.dialogue.remove_dialogue_script("highlight_axe")
	TPLG.dialogue.remove_dialogue_script("highlight_soil_with_trees")


func _setup_farm_grid_one():
	farm_grid.data = _generate_farm_grid_data_object()
	farm_grid.data.forageItems = [
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 0,
			"variant": 0,
			"x": 1,
			"y": 1
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 0,
			"variant": 1,
			"x": 1,
			"y": 2
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 0,
			"variant": 2,
			"x": 1,
			"y": 3
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": false,
			"health": 10,
			"type": 0,
			"variant": 0,
			"x": 1,
			"y": 4
		}
	]
	farm_grid.call_deferred("draw_things_from_data")


func _setup_farm_grid_two():
	farm_grid_2.data = _generate_farm_grid_data_object()
	farm_grid_2.data.forageItems = [
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 1,
			"variant": 0,
			"x": 1,
			"y": 1
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": false,
			"health": 10,
			"type": 3,
			"variant": 0,
			"x": 1,
			"y": 2
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 1,
			"variant": 2,
			"x": 1,
			"y": 3
		},
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": true,
			"health": 10,
			"type": 3,
			"variant": 0,
			"x": 1,
			"y": 4
		}
	]
	farm_grid_2.call_deferred("draw_things_from_data")


func _setup_farm_grid_three():
	farm_grid_3.data = _generate_farm_grid_data_object()
	farm_grid_3.data.forageItems = [
		{
			"damageOnHit": 10,
			"dropItems": {},
			"flippedX": false,
			"health": 10,
			"type": 2,
			"variant": 0,
			"x": 1,
			"y": 2
		}
	]
	farm_grid_3.call_deferred("draw_things_from_data")


func _generate_farm_grid_data_object():
	return {"forageItems": [], "plants": [], "craftedItems": [], "groundTiles": {}}


func highlight_pickaxe():
	item_idx = 2
	has_highlighted_dialogue_idx = "pickaxeSelected"
	highlight_item()


func highlight_soil_with_stones():
	tiles_to_highlight.clear()

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(tile_offset + Vector2(x, y))

	has_completed_farm_task_idx = "pickaxeUsed"
	highlight_soil()


func highlight_scythe():
	item_idx = 3
	has_highlighted_dialogue_idx = "scytheSelected"
	farm_grid = farm_grid_2
	highlight_item()


func highlight_soil_with_weeds():
	tiles_to_highlight.clear()

	tile_offset = farm_grid_2.position + Vector2(1, 1)

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(tile_offset + Vector2(x, y))

	has_completed_farm_task_idx = "scytheUsed"
	highlight_soil()


func highlight_axe():
	item_idx = 4
	has_highlighted_dialogue_idx = "axeSelected"
	farm_grid = farm_grid_3
	highlight_item()


func higlight_soil_with_trees():
	tiles_to_highlight.clear()

	tile_offset = farm_grid_3.position + Vector2(1, 1)

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(tile_offset + Vector2(x, y))

	has_completed_farm_task_idx = "axeUsed"
	block_mission_finish = false
	highlight_soil()
