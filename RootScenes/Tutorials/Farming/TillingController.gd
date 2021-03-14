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
	if ! TPLG.inventory.tiles[0].is_connected("select_slot", self, "_has_highlighted"):
		# determine which inventory slot has the tiller
		# - as the user can't move items currently, it'll always be in the 0 slot for now
		TPLG.inventory.tiles[0].point_at_tile()
		TPLG.inventory.tiles[0].connect("equip_item", self, "_has_highlighted", [0])


func _has_highlighted(_slot: int):
	# determine which inventory slot has the tiller
	# - as the user can't move items currently, it'll always be in the 0 slot for now
	TPLG.inventory.tiles[0].disconnect("equip_item", self, "_has_highlighted")
	TPLG.inventory.tiles[0].stop_pointing()

	TPLG.dialogue.start("JKJZ/TillTutorial", "playerHasSelectedTiller")


func highlight_soil():
	root_controller.tile_highlighter.highlight(Vector2(16, 9), Vector2(20, 13))
