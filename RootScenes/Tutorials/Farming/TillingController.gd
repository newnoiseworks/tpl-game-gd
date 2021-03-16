extends Node2D

onready var jkjz = $JKJZ
onready var root_controller = get_parent().get_parent().get_parent()
onready var player_entry = root_controller.get_node("PlayerEntry")
onready var timer: Timer = $Timer
onready var farm_grid = $FarmGrid


func _ready():
	TPLG.dialogue.add_dialogue_script("highlight_tiller", self)
	TPLG.dialogue.add_dialogue_script("highlight_soil", self)

	TPLG.current_farm_grids = [farm_grid]

	jkjz._move_event({"ping": "0", "x": player_entry.position.x + 16, "y": player_entry.position.y})

	timer.one_shot = true
	timer.wait_time = 3
	timer.connect("timeout", self, "_deliver_intro_dialogue")
	timer.start()


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
			farm_grid.position / 16, farm_grid.position / 16 + Vector2(4, 4)
		)


func _handle_farming_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != Player.user_id:
		return

	var args = JSON.parse(msg).result

	if int(args.type) == FarmEvent.TILL:
		root_controller.tile_highlighter.unhighlight_tile(
			farm_grid.position / 16 + Vector2(args.x, args.y)
		)

		# TODO: Track if all necessary tiles have been tilled. Need to construct an array of Vector2's probably (PoolVector2?)
