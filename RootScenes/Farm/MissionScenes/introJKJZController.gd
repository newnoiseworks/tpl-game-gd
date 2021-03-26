extends YSort

onready var jkjz_character = $JKJZ
onready var exit: Node2D = $Exit
onready var teleporter: Node2D = get_parent().get_parent().get_parent().get_node(
	"LeftEntry/Teleporter"
)


func _ready():
	TPLG.dialogue.add_dialogue_script("intro_jkjz_finish", self)
	TPLG.dialogue.add_dialogue_script("start_till_tutorial", self)
	jkjz_character.highlight()
	teleporter.position += Vector2(-9999, 0)


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("intro_jkjz_finish")
	TPLG.dialogue.remove_dialogue_script("start_till_tutorial")


func start_till_tutorial():
	TPLG.base_change_scene(
		"res://RootScenes/Tutorials/Farming/FarmingTutorials.tscn", {}, false, false
	)


func intro_jkjz_finish():
	var pos = exit.position
	teleporter.position -= Vector2(-9999, 0)

	yield(TPLG.ui.mission_list.finish_mission("introJKJZ"), "completed")
	yield(TPLG.ui.mission_list.start_mission("sayHiToSakana"), "completed")
	yield(TPLG.ui.mission_list.start_mission("sayHiToBaph"), "completed")
	yield(TPLG.ui.mission_list.start_mission("learnEconFromJKJZ"), "completed")
	yield(TPLG.ui.mission_list.start_mission("visitTown"), "completed")

	jkjz_character._move_event({"ping": "0", "x": pos.x, "y": pos.y})
	jkjz_character.highlight(false)
	jkjz_character.set_collision_layer_bit(1, false)

	TPLG.ui.mission_list.reload_missions()
