tool
extends GraphNode

const character_list: Array = [
	"(choose character)", "Sakana", "Baph", "JKJZ", "York", "Gil", "Violine", "ComputerHaus"
]

const missions = preload("res://Utils/MissionList.gd")

var file: ConfigFile
var section: String
var file_path: String

onready var key_input = find_node("Key")
onready var text_input = find_node("Text")
onready var option_text = find_node("OptionText")
onready var script_input = find_node("Script")
onready var character_choice = find_node("CharacterChoice")
onready var mission_reqs = find_node("MissionReqs")


func _set_resource(_file: ConfigFile):
	file = _file


func _ready():
	key_input.text = section

	if file.has_section_key(section, "text"):
		text_input.text = file.get_value(section, "text")

	if file.has_section_key(section, "optionText"):
		option_text.text = file.get_value(section, "optionText")

	if file.has_section_key(section, "script"):
		script_input.text = file.get_value(section, "script")

	_setup_character_list_on_ready()
	_setup_mission_prereqs_on_ready()


func _setup_character_list_on_ready():
	var whom = ""
	if file.has_section_key(section, "whom"):
		whom = file.get_value(section, "whom")

	var i = 0
	for character in character_list:
		character_choice.add_item(character, i)
		if whom == character:
			character_choice.call_deferred("select", i)
		i = i + 1


func _setup_mission_prereqs_on_ready():
	var mission_prereqs = []
	if file.has_section_key(section, "missionPrereqs"):
		mission_prereqs = file.get_value(section, "missionPrereqs").replace(" ", "").split(",")

	var i = 0
	for mission_key in missions.list:
		if mission_key != null || mission_key != "":
			mission_reqs.get_popup().add_check_item(mission_key, i)
			if mission_key in mission_prereqs:
				mission_reqs.get_popup().toggle_item_checked(i)
			i = i + 1

	mission_reqs.get_popup().connect("index_pressed", self, "_on_MissionReqsPopup_index_pressed")


func _exit_tree():
	mission_reqs.get_popup().disconnect("index_pressed", self, "_on_MissionReqsPopup_index_pressed")


func _on_MissionReqsPopup_index_pressed(idx: int):
	var mission_key = missions.list.keys()[idx]
	var is_on = mission_reqs.get_popup().is_item_checked(idx)
	var turning_on = ! is_on

	mission_reqs.get_popup().set_item_checked(idx, ! is_on)

	var mission_prereqs = []
	if file.has_section_key(section, "missionPrereqs"):
		mission_prereqs = Array(
			file.get_value(section, "missionPrereqs").replace(" ", "").split(",")
		)

	if turning_on:
		mission_prereqs.append(mission_key)
	else:
		mission_prereqs.erase(mission_key)

	file.set_value(section, "missionPrereqs", PoolStringArray(mission_prereqs).join(","))


func _on_DialogueNode_dragged(_from: Vector2, to: Vector2):
	file.set_value(section, "offsetX", to.x)
	file.set_value(section, "offsetY", to.y)


func _on_Text_text_changed():
	file.set_value(section, "text", text_input.text)


func _on_CharacterChoice_item_selected(index: int):
	if index == 0:
		file.erase_section_key(section, "whom")
	else:
		file.set_value(section, "whom", character_list[index])


func _on_OptionText_text_changed(text: String):
	if text == "":
		file.erase_value(section, "option_text")
	else:
		file.set_value(section, "optionText", text)


func _on_Script_text_changed(text: String):
	if text == "":
		file.erase_value(section, "script")
	else:
		file.set_value(section, "script", text)


func _on_DialogueNode_close_request():
	if file.has_section(section):
		file.erase_section(section)

	var connections = get_parent().get_connection_list()

	for connection in connections:
		if connection.to == section && connection.to_port == 0:
			get_parent()._on_MainScreen_disconnection_request(
				connection.from, connection.from_port, connection.to, connection.to_port
			)

	get_parent()._nodes.erase(section)

	queue_free()
