tool
extends GraphEdit

var DialogueNode
var ScriptNode
var _sections: Array
var _path: String = ""
var node_types: Dictionary = {}
var _nodes: Dictionary = {}

signal reset_file

onready var _current_resource: ConfigFile = ConfigFile.new()
onready var add_button: MenuButton = find_node("AddButton")
onready var _new_node_section_name = find_node("NewNodeName")


func _ready():
	var _c = add_button.get_popup().connect(
		"index_pressed", self, "_on_AddButtonPopup_index_pressed"
	)


func _exit_tree():
	add_button.get_popup().disconnect("index_pressed", self, "_on_AddButtonPopup_index_pressed")


func _file_loaded(path):
	var _p = _current_resource.load(path)
	_sections = _current_resource.get_sections()
	_path = path

	var offset_width: int = 420
	var current_offset: int = 0

	for section in _sections:
		var dnode

		if section.ends_with("Entry"):
			dnode = node_types.MissionEntry.instance()
		elif section.ends_with("Exit"):
			dnode = node_types.MissionExit.instance()
		elif section.ends_with("ExitFinished"):
			dnode = node_types.MissionExitFinished.instance()
		elif section.ends_with("ExitFailed"):
			dnode = node_types.MissionExitFailed.instance()
		elif section.ends_with("StartMissionScript"):
			dnode = node_types.StartMissionScript.instance()
			dnode.starting_mission_key = section.replace("StartMissionScript", "")
		elif section.ends_with("FinishMissionScript"):
			dnode = node_types.FinishMissionScript.instance()
			dnode.starting_mission_key = section.replace("FinishMissionScript", "")
		elif _current_resource.has_section_key(section, "script"):
			dnode = node_types.Script.instance()
		else:
			dnode = node_types.Dialogue.instance()

		dnode.name = section
		dnode.file = _current_resource
		dnode.file_path = path
		dnode.section = section

		if (
			_current_resource.has_section_key(section, "offsetX")
			&& _current_resource.has_section_key(section, "offsetY")
		):
			dnode.offset += Vector2(
				_current_resource.get_value(section, "offsetX"),
				_current_resource.get_value(section, "offsetY")
			)
		else:
			dnode.offset += Vector2(current_offset, 0)
			current_offset += offset_width

		_nodes[section] = dnode
		add_child(dnode)

	_draw_dialogue_connections()


func _draw_dialogue_connections():
	for section in _sections:
		var connections: Array = []

		if _current_resource.has_section_key(section, "next"):
			connections.append(
				{
					"section": section,
					"from_slot": 0,
					"to": _current_resource.get_value(section, "next"),
					"to_slot": 0
				}
			)

		if _current_resource.has_section_key(section, "options"):
			for option in _current_resource.get_value(section, "options").split(","):
				connections.append(
					{
						"section": section,
						"from_slot": 0,
						"to": option.replace(" ", ""),
						"to_slot": 0
					}
				)

		if (
			section.ends_with("FinishMissionScript")
			&& _current_resource.has_section_key(section, "scriptArgs")
		):
			var args = Array(_current_resource.get_value(section, "scriptArgs").split(","))

			if args.size() > 3 && args[3] != "":  # fail node
				connections.append(
					{"section": section, "from_slot": 1, "to": args[3], "to_slot": 0}
				)

			if args.size() > 4 && args[4] != "":  # finish node
				connections.append(
					{"section": section, "from_slot": 0, "to": args[4], "to_slot": 0}
				)

		for connection in connections:
			var _slot = connect_node(
				connection.section, connection.from_slot, connection.to, connection.to_slot
			)


func _on_MainScreen_connection_request(from: String, from_slot: int, to: String, to_slot: int):
	var _slot = connect_node(from, from_slot, to, to_slot)

	var from_node = _nodes[from]
	var to_node = _nodes[to]

	if from_slot == 0 && to_slot == 0:
		if to_node.get_slot_type_left(to_slot) == 0:
			if _current_resource.has_section_key(from, "next"):
				var value = _current_resource.get_value(from, "next")

				if value == to:
					return

				_current_resource.erase_section_key(from, "next")
				_current_resource.set_value(from, "options", "%s, %s" % [value, to])
			elif _current_resource.has_section_key(from, "options"):
				var value = _current_resource.get_value(from, "options")

				if to in value:
					return

				_current_resource.set_value(from, "options", "%s,%s" % [value, to])
			else:
				_current_resource.set_value(from, "next", to)
		elif to_node.get_slot_type_left(to_slot) == 1:
			from_node.handle_finish_connection_request(to)
	elif from_slot == 1 && to_slot == 0 && to_node.get_slot_type_left(to_slot) == 2:
		from_node.handle_fail_connection_request(to)


func _on_MainScreen_disconnection_request(from: String, from_slot: int, to: String, to_slot: int):
	disconnect_node(from, from_slot, to, to_slot)

	var from_node = _nodes[from]
	var to_node = _nodes[to]

	if from_slot == 0 && to_slot == 0:
		if to_node.get_slot_type_left(to_slot) == 0:
			if _current_resource.has_section_key(from, "next"):
				_current_resource.erase_section_key(from, "next")
			elif _current_resource.has_section_key(from, "options"):
				var value = _current_resource.get_value(from, "options")
				var options: Array = value.replace(" ", "").split(",")
				options.erase(to)

				value = PoolStringArray(options).join(",")

				if options.size() > 1:
					_current_resource.set_value(from, "options", value)
				else:
					_current_resource.set_value(from, "next", value)
					_current_resource.erase_section_key(from, "options")
		elif to_node.get_slot_type_left(to_slot) == 1:
			from_node.handle_finish_disconnection_request(to)
	elif from_slot == 1 && to_slot == 0 && to_node.get_slot_type_left(to_slot) == 2:
		from_node.handle_fail_disconnection_request(to)


func _on_ResetButton_pressed():
	emit_signal("reset_file")

	_current_resource = ConfigFile.new()
	_path = ""
	_sections = []

	clear_connections()

	for child in get_children():
		if child is GraphNode:
			child.queue_free()


func _on_SaveButton_pressed():
	if _path != "":
		var _s = _current_resource.save(_path)


func _on_AddButtonPopup_index_pressed(idx: int):
	var text = _new_node_section_name.text
	var full_err_msg = "Node name cannot end with Entry, Exit, ExitFinished, ExitFailed, StartMissionScriptNode, or FinishMissionScriptNode"

	if text == null || text == "":
		printerr("New nodes require a name")
		return
	elif text.ends_with("Entry"):
		printerr(full_err_msg)
		return
	elif text.ends_with("Exit"):
		printerr(full_err_msg)
		return
	elif text.ends_with("ExitFinished"):
		printerr(full_err_msg)
		return
	elif text.ends_with("ExitFailed"):
		printerr(full_err_msg)
		return
	elif text.ends_with("StartMissionScript"):
		printerr(full_err_msg)
		return
	elif text.ends_with("FinishMissionScript"):
		printerr(full_err_msg)
		return

	var type = node_types.keys()[idx]
	var dnode = node_types[type].instance()
	dnode.file = _current_resource
	dnode.file_path = _path

	match type:
		'MissionEntry':
			dnode.name = text + "Entry"
		'MissionExit':
			dnode.name = text + "Exit"
		'MissionExitFinished':
			dnode.name = text + "ExitFinished"
		'MissionExitFailed':
			dnode.name = text + "ExitFailed"
		'StartMissionScript':
			dnode.name = text + "StartMissionScript"
			dnode.starting_mission_key = text
		'FinishMissionScript':
			dnode.name = text + "FinishMissionScript"
			dnode.starting_mission_key = text
		_:
			dnode.name = text

	dnode.section = dnode.name
	_nodes[dnode.name] = dnode
	add_child(dnode)


func _on_NewNodeName_text_changed(_text: String):
	pass
