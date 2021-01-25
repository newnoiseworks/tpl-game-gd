tool
extends "res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/StartMissionScriptNodeController.gd"

onready var reload_inventory_check = find_node("ReloadInventoryCheck")
onready var dialogue_file_input = find_node("DialogueFileInput")


func _ready():
	file.set_value(section, "script", "finish_mission")

	_set_args()

	if _args[0] == "" && starting_mission_key != "" && starting_mission_key != null:
		_args.insert(0, starting_mission_key)

	reload_inventory_check.pressed = _args[1] == "true"

	if _args[2] != "":
		dialogue_file_input.text = _args[2]


func _set_args():
	var args = Array(file.get_value(section, "scriptArgs", "").split(","))
	var finished_args = []

	for i in range(5):
		if ! args.size() > i:
			finished_args.insert(i, "")
		else:
			finished_args.insert(i, args[i])

	_args = finished_args


func _update_args():
	file.set_value(section, "scriptArgs", PoolStringArray(_args).join(","))


func _on_MissionChooser_item_selected(index: int):
	_args[0] = missions.list.keys()[index]
	_update_args()


func _on_ReloadInventoryCheck_toggled(on: bool):
	_args[1] = "true" if on else "false"
	_update_args()


func _on_DialogueFileInput_text_changed(text: String):
	_args[2] = text
	_update_args()


func handle_finish_connection_request(to: String):
	_args[4] = to
	_update_args()


func handle_finish_disconnection_request(_to: String):
	_args[4] = ""
	_update_args()


func handle_fail_connection_request(to: String):
	_args[3] = to
	_update_args()


func handle_fail_disconnection_request(_to: String):
	_args[3] = ""
	_update_args()
