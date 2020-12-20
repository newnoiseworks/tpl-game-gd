extends Control

# holds signals & objects in a dictionary, emits signal on object as dialogue files request it
var dialogue_scripts = {}


func add_dialogue_script(method: String, node: Node):
	dialogue_scripts[method] = node


func remove_dialogue_script(method: String):
	dialogue_scripts.erase(method)


const TYPEWRITER_SPEED: int = 25
const MAX_DIALOGUE_CHARS: int = 90
const MAX_DIALOGUE_CHARS_WITH_AVATAR: int = 75
const ELIPSES: String = "..."

onready var current_text: RichTextLabel = find_node("Dialogue")
onready var dialogue_text: RichTextLabel = find_node("AvatarDialogue")
onready var avatar_tilemap: TileMap = find_node("TileMap")
onready var option_list: ItemList = find_node("Options")
onready var whomst: TextEdit = find_node("WhomstContainer")

var text: RichTextLabel
var avatar_tile: Vector2 = Vector2(0, 0)
var type_timer: Timer = Timer.new()
var next_char_pos: int
var bbcode: PoolStringArray = []
var is_typing: bool
var dialogue_step = {}
var dialogue_options: Array = []
var next_dialogue_option_index: int = -1
var cut_off_bb_code: bool
var dialogue_filename: String


func _ready():
	TPLG.set_dialogue(self)
	text = current_text
	type_timer.wait_time = TYPEWRITER_SPEED
	type_timer.autostart = false
	type_timer.connect("timeout", self, "type_timer_elapsed")
	add_child(type_timer)


func _input(event):
	if ! visible:
		return

	if event.is_action_released("action_one") || event.is_action_released("action_two"):
		if is_typing:
			is_typing = false
		elif cut_off_bb_code:
			continue_bb_code()
		elif next_dialogue_option_index > -1:
			handle_option_selection()
		elif dialogue_step[I18n.options_key] != null:
			start_options()
		elif dialogue_step[I18n.next_key] != null:
			start_step(I18n.get_dialogue_step(dialogue_filename, dialogue_step[I18n.next_key]))
		elif dialogue_step[I18n.script_key] != null:
			run_script(dialogue_step)
		elif visible:
			get_tree().set_input_as_handled()
			hide_dialogs()


func hide_dialogs():
	TPLG.dialogue.hide()
	Player.call_deferred("set", "lock_movement", false)


func dialogue_option_selected(index: int):
	next_dialogue_option_index = index


# WELP: It would be really nice if, as a precautionary measure, we checked the Dialogue file for any "script" references, and then make sure that DialogueController.dialogueScripts contains delegates for every corresponding key before starting.
func start(_dialogue_filename: String, section: String):
	dialogue_filename = _dialogue_filename
	start_step(I18n.get_dialogue_step(dialogue_filename, section))


func start_step(_dialogue_step):
	Player.lock_movement = true
	dialogue_step = _dialogue_step
	update_speaker()
	option_list.hide()
	next_dialogue_option_index = -1
	next_char_pos = 0
	is_typing = true

	if cut_off_bb_code:
		cut_off_bb_code = false
	elif dialogue_step[I18n.text_key] is String:
		bbcode = dialogue_step[I18n.text_key].split("")
	elif dialogue_step[I18n.script_key] is String:
		hide_dialogs()
		run_script_from_step()
		return

	current_text.bbcode_text = ""
	show()
	typewrite()


func typewrite():
	if (
		(current_text == text && current_text.text.length() >= MAX_DIALOGUE_CHARS)
		|| (
			current_text != text
			&& current_text.text.length() >= MAX_DIALOGUE_CHARS_WITH_AVATAR
			&& bbcode[next_char_pos - 1] == " "
		)
	):
		is_typing = false
		bbcode = bbcode.join("").replace(current_text.bbcode_text, "... ").split("")
		current_text.bbcode_text += ELIPSES
		cut_off_bb_code = true
		return
	elif next_char_pos >= bbcode.size():
		is_typing = false
		return

	type_next_character()


func type_next_character():
	var _text = ""

	while _text == "":
		_text += bbcode[next_char_pos]
		next_char_pos += 1

		if _text != "":
			current_text.bbcode_text += _text

	if is_typing:
		type_timer.start()
	else:
		typewrite()


func type_timer_elapsed():
	type_timer.stop()
	typewrite()


func update_speaker():
	text.bbcode_text = ""
	dialogue_text.bbcode_text = ""
	avatar_tilemap.clear()
	current_text = text
	whomst.hide()

	if dialogue_step[I18n.whom_key] != null:
		var character_name: String = dialogue_step[I18n.whom_key]

		whomst.show()
		whomst.text = character_name.strip_edges(true, true)

		var portrait_tile: int = avatar_tilemap.tile_set.find_tile_by_name(
			"Characters/NPC PORTRAITS/%s/Standard Face" % [character_name]
		)

		if portrait_tile > -1:
			current_text = dialogue_text
			avatar_tilemap.set_cellv(avatar_tile, portrait_tile)
		else:
			avatar_tilemap.clear()


func start_options():
	var options: PoolStringArray = dialogue_step[I18n.options_key].replace(" ", "").split(',')
	var whom: String = dialogue_step[I18n.whom_key]
	dialogue_options = []
	option_list.clear()
	option_list.show()

	# Consider moving around the below to an independent method
	var completed_missions = TPLG.ui.mission_list.get_completed_mission_keys()
	var current_missions = TPLG.ui.mission_list.get_current_mission_keys()

	for character_key in TPLG.current_root_scene.mission_dialogue_options:
		if whom == character_key:
			var character_info = TPLG.current_root_scene.mission_dialogue_options[character_key]

			for mission_key in character_info.mission_entries:
				if mission_key in completed_missions || mission_key in current_missions:
					continue

				var can_have_mission: bool = true

				for prereq in MissionList.list[mission_key].prereqs.split(","):
					if ! (prereq in completed_missions):
						can_have_mission = false

				if can_have_mission:
					options.append("%sEntry" % mission_key)

			for mission_key in character_info.mission_exits:
				if mission_key in current_missions:
					options.append("%sExit" % mission_key)

	for key in options:
		var can_have_option: bool = true

		var dialogue_option = I18n.get_dialogue_step(dialogue_filename, key)

		if dialogue_option[I18n.mission_prereqs_key] != null:
			for prereq in dialogue_option[I18n.mission_prereqs_key].split(","):
				if ! (prereq in completed_missions):
					can_have_option = false

		if ! can_have_option:
			continue

		dialogue_options.append(dialogue_option)
		option_list.add_item(dialogue_option[I18n.option_text_key])


func handle_option_selection():
	var option = dialogue_options[next_dialogue_option_index]

	if option[I18n.script_key] != null:
		run_script(option)
	else:
		start_step(option)


func continue_bb_code():
	start_step(dialogue_step)


func run_script(_dialogue_step):
	dialogue_step = _dialogue_step
	option_list.hide()
	next_dialogue_option_index = -1
	call_deferred("hide_dialogs")

	run_script_from_step()


func run_script_from_step():
	var script_key: String = dialogue_step[I18n.script_key]

	if dialogue_scripts.has(script_key):
		dialogue_scripts[script_key].call(script_key)
	else:
		print_debug(
			(
				"Dialogue scriptKey not defined, check initial DialogueController.Start() call and make sure DialogueController.dialogScripts[\"%s\"] is setup w/ a callback"
				% [script_key]
			)
		)
