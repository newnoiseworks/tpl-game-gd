tool
extends "res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/DialogueNodeController.gd"

onready var mission_chooser = find_node("MissionChooser")

var starting_mission_key: String = ""

var _args = []


func _ready():
	var i = 0

	file.set_value(section, "script", "start_mission")

	for mission_key in missions.list:
		mission_chooser.add_item(mission_key, i)
		if starting_mission_key == mission_key:
			mission_chooser.call_deferred("select", i)
		i = i + 1

	_set_args()


func _set_args():
	file.set_value(section, "scriptArgs", starting_mission_key)


func _on_MissionChooser_item_selected(index: int):
	var mission_key = missions.list.keys()[index]
	if index == 0:
		file.erase_section_key(section, "scriptArgs")
	else:
		file.set_value(section, "scriptArgs", mission_key)
