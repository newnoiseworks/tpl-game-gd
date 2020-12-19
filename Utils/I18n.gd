extends Node

var files: Dictionary = {}

var lang: String = "EN"

var text_key: String = "text"
var next_key: String = "next"
var script_key: String = "script"
var options_key: String = "options"
var option_text_key: String = "optionText"
var whom_key: String = "whom"
var mission_prereqs_key: String = "missionPrereqs"


func get_line(filename: String, section: String, key: String):
	return get_key_if_exists_in_file(filename, section, key)


func get_dialogue_step(filename: String, section: String):
	var step = {}

	step[text_key] = get_key_if_exists_in_file(filename, section, text_key)
	step[next_key] = get_key_if_exists_in_file(filename, section, next_key)
	step[script_key] = get_key_if_exists_in_file(filename, section, script_key)
	step[options_key] = get_key_if_exists_in_file(filename, section, options_key)
	step[option_text_key] = get_key_if_exists_in_file(filename, section, option_text_key)
	step[whom_key] = get_key_if_exists_in_file(filename, section, whom_key)
	step[mission_prereqs_key] = get_key_if_exists_in_file(filename, section, mission_prereqs_key)

	return step


func get_key_if_exists_in_file(filename: String, section: String, key: String = ""):
	var file = get_file(filename)

	if file.has_section_key(section, key):
		return String(file.get_value(section, key))
	else:
		return null


func load_file(filename: String):
	files[filename] = ConfigFile.new()
	files[filename].load("res://Resources/Dialogue/%s/%s.tres" % [lang, filename])


func get_file(filename: String):
	if files.has(filename) == false:
		load_file(filename)

	return files[filename]
