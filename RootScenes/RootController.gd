extends Node2D

export var scene_name: String

# var debug_window_scene: PackedScene = ResourceLoader.load("res://Scenes/UI/DebugWindow.tscn")
# var teleporter_scene: PackedScene = ResourceLoader.load("res://Scenes/MovementGrid/Teleporter.tscn")

var zoom_offset: float = 3

var mission_scenes = {}
var mission_dialogue_options = {}

onready var mission_launcher_node = find_node("MissionLauncher")


func _ready():
	# add_child(debug_window_scene.instance())
	window_size_setup()
	mission_setup()
	TPLG.current_root_scene = self


# TODO: consider moving the mission stuff into an isolated node, perhaps the mission_launcher_node itself
func mission_setup():
	if mission_launcher_node == null:
		return

	yield(TPLG.ui.mission_list.reload_missions(), "completed")

	var current_missions = TPLG.ui.mission_list.current_missions
	for mission in current_missions:
		if mission.key in mission_scenes.keys():
			var mission_scene = ResourceLoader.load(mission_scenes[mission.key])
			var instance = mission_scene.instance()
			mission_launcher_node.call_deferred("add_child", instance)

	mission_character_highlight_setup()


func _finish_mission(mission_key: String, update_inventory: bool = false, exit_dialog_avatar: String = "") -> bool:
	var passed = yield(TPLG.ui.mission_list.finish_mission(mission_key), "completed")

	if passed.payload == "false":
		return false
	else:
		if update_inventory:
			TPLG.inventory.bag.reload_and_redraw_data({}, {})

		TPLG.wallet.sync_with_wallet()
		yield(TPLG.ui.mission_list.reload_missions(), "completed")
		mission_character_highlight_setup()

	if exit_dialog_avatar != "":
		if passed.payload == "false":
			TPLG.dialogue.start(exit_dialog_avatar, "%sExitFailed" % mission_key)
		else:
			TPLG.dialogue.start(exit_dialog_avatar, "%sExitFinished" % mission_key)
		
	return true


func _start_mission(mission_key: String):
	yield(TPLG.ui.mission_list.start_mission(mission_key), "completed")
	yield(TPLG.ui.mission_list.reload_missions(), "completed")
	mission_character_highlight_setup()

func mission_character_highlight_setup():
	for character_key in mission_dialogue_options:
		character_highlight(character_key, false)

	var current_missions = TPLG.ui.mission_list.current_missions
	var current_mission_keys = TPLG.ui.mission_list.get_current_mission_keys()
	var completed_missions = TPLG.ui.mission_list.get_completed_mission_keys()

	for character_key in mission_dialogue_options:
		if "mission_entries" in mission_dialogue_options[character_key]:
			var entries = mission_dialogue_options[character_key]["mission_entries"]

			for mission_key in entries:
				var mission_data = MissionList.list[mission_key]
				var has_passed = true

				if mission_key in current_mission_keys || mission_key in completed_missions:
					has_passed = false

				if has_passed && "prereqs" in mission_data:
					# highlight characters in scene if they enter a mission AND the user matches those prereqs

					for req in mission_data.prereqs.split(","):
						if ! req in completed_missions:
							has_passed = false
							break

				if has_passed == true:
					print_debug(
						(
							"highlighting character %s based on mission_entry of mission %s"
							% [character_key, mission_key]
						)
					)
					character_highlight(character_key)

	# highlight characters in scene if they exit a mission AND the user matches those reqs
	for mission in current_missions:
		for character_key in mission_dialogue_options:
			if "mission_exits" in mission_dialogue_options[character_key]:
				var exits = mission_dialogue_options[character_key]["mission_exits"]

				for mission_key in exits:
					var mission_data = MissionList.list[mission_key]

					if "reqs" in mission_data || "prereqs" in mission_data:
						var can_pass = true

						if mission_key in completed_missions:
							can_pass = false

						if can_pass && "reqs" in mission_data:
							for item_key in mission_data.reqs:
								if (
									TPLG.inventory.bag.has_item(
										item_key, mission_data.reqs[item_key]
									)
									== false
								):
									can_pass = false
									break

						if can_pass && "prereqs" in mission_data:
							for req in mission_data.prereqs.split(","):
								if ! req in completed_missions:
									can_pass = false
									break

						if can_pass == true:
							print_debug(
								(
									"highlighting character %s based on mission_exit of mission %s"
									% [character_key, mission_key]
								)
							)
							character_highlight(character_key)
					elif ! mission_key in completed_missions:
						print_debug(
							(
								"highlighting character %s based on mission_exit of mission %s"
								% [character_key, mission_key]
							)
						)
						character_highlight(character_key)


func character_highlight(character_key: String, on: bool = true):
	var character = find_node(character_key)
	if character != null:
		character.highlight(on)


func window_size_setup():
	OS.min_window_size = Vector2(1280, 720)
	get_tree().root.connect("size_changed", self, "on_window_resize")


func on_window_resize():
	var vp = get_viewport()

	if vp == null:
		return

	vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y) / zoom_offset)
	vp.size_override_stretch = true

	if Player.is_inside_tree():
		var camera: Camera2D = Player.camera
		var width: int = int(
			abs(camera.limit_left) * zoom_offset + abs(camera.limit_right) * zoom_offset
		)

		if OS.window_size.x > width:
			camera.offset = Vector2(int((OS.window_size.x - width) / 2) / zoom_offset, 0)
		else:
			camera.offset = Vector2()
