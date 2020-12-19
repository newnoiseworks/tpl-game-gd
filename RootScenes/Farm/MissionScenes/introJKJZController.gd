extends Node2D

signal intro_jkjz_finish

onready var jkjz_character = $JKJZ
onready var exit: Node2D = $Exit


func _ready():
	TPLG.dialogue.add_dialogue_script("intro_jkjz_finish", self)
	connect("intro_jkjz_finish", self, "finish_intro_mission")


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("intro_jkjz_finish")
	disconnect("intro_jkjz_finish", self, "finish_intro_mission")


func finish_intro_mission():
	var pos = exit.position
	jkjz_character._move_event({"ping": "0", "x": pos.x, "y": pos.y})

	yield(TPLG.ui.mission_list.finish_mission("introJKJZ"), "completed")
	yield(TPLG.ui.mission_list.start_mission("sayHiToSakana"), "completed")

	TPLG.ui.mission_list.reload_missions()
