extends Node2D

onready var jkjz = $JKJZ
onready var root_controller = get_parent().get_parent().get_parent()
onready var player_entry = root_controller.get_node("PlayerEntry")
onready var timer: Timer = $Timer
onready var farm_grid = $FarmGrid

var tiles_to_highlight: Array = []
var tiles_to_highlight_size: Vector2 = Vector2(4, 4)


func _ready():
	farm_grid.setup_collider()

	TPLG.dialogue.add_dialogue_script("highlight_tiller", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil", self)

	TPLG.current_farm_grids = [farm_grid]

	jkjz._move_event({"ping": "0", "x": player_entry.position.x + 16, "y": player_entry.position.y})

	if (
		! "tutorialFarmingTilling" in TPLG.ui.mission_list.get_current_mission_keys()
		&& ! "tutorialFarmingTilling" in TPLG.ui.mission_list.get_completed_mission_keys()
	):
		root_controller.start_mission("tutorialFarmingTilling")

	timer.one_shot = true
	timer.wait_time = 3
	timer.connect("timeout", self, "_deliver_intro_dialogue")
	timer.start()

	for x in range(tiles_to_highlight_size.x):
		for y in range(tiles_to_highlight_size.y):
			tiles_to_highlight.append(Vector2(x, y))


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("highlight_tiller")
	TPLG.dialogue.remove_dialogue_script("highlight_soil")


func _deliver_intro_dialogue():
	timer.disconnect("timeout", self, "_deliver_intro_dialogue")
	TPLG.dialogue.start("JKJZ", "tillTutorialBegin")


func highlight_tiller():
	# determine which inventory slot has the tiller
	# - as the user can't move items currently, it'll always be in the 0 slot for now
	var tiller_idx = 0
	var tiller = TPLG.inventory.tiles[tiller_idx]

	if ! tiller.is_connected("select_slot", self, "_has_highlighted"):
		tiller.point_at_tile()
		tiller.connect("equip_item", self, "_has_highlighted", [tiller_idx])


func _has_highlighted(slot: int):
	var tiller = TPLG.inventory.tiles[slot]

	tiller.stop_pointing()
	tiller.disconnect("equip_item", self, "_has_highlighted")

	TPLG.dialogue.start("JKJZ/TillTutorial", "playerHasSelectedTiller")


func highlight_soil():
	if ! MatchEvent.is_connected("farming", self, "_handle_farming_event"):
		MatchEvent.connect("farming", self, "_handle_farming_event")

		root_controller.tile_highlighter.highlight(
			farm_grid.position / 16, farm_grid.position / 16 + tiles_to_highlight_size
		)


func _handle_farming_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != Player.user_id:
		return

	var args = JSON.parse(msg).result

	if int(args.type) == FarmEvent.TILL:
		var tile_pos = Vector2(args.x, args.y)

		root_controller.tile_highlighter.unhighlight_tile(farm_grid.position / 16 + tile_pos)

		if tile_pos in tiles_to_highlight:
			tiles_to_highlight.erase(tile_pos)

		if tiles_to_highlight.size() == 0:
			# TODO: Add some dialogue from JKJZ w/ options to move to next farming tutorial
			print_debug("Jobs' done")

			if "tutorialFarmingTilling" in TPLG.ui.mission_list.get_current_mission_keys():
				root_controller.finish_mission("tutorialFarmingTilling")
