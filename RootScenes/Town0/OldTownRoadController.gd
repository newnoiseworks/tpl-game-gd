extends "res://RootScenes/DungeonController.gd"

var player_context_menu_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/PlayerContextMenu.tscn"
)

var town_teleporter


func _init():
	mission_dialogue_options = {
		"Sakana":
		{
			"mission_entries": ["tomatoesForSakana"],
			"mission_exits": ["sayHiToSakana", "tomatoesForSakana"],
		},
		"Baph": {
			"mission_exits": ["sayHiToBaph"],
		},
		"York": {"mission_entries": ["pickupYorksHearts"], "mission_exits": ["pickupYorksHearts"]},
		"Gil": {"mission_entries": ["catchGilAFish"], "mission_exits": ["catchGilAFish"]}
	}

	mission_scenes = {
		"pickupYorksHearts":
		"res://RootScenes/Town0/MissionScenes/PickupYorksHearts/PickupYorksHearts.tscn"
	}


func _ready():
	setup_teleporter()

	RealmEvent.connect("realm_join", self, "realm_join_event_response")
	RealmEvent.connect("change_dungeon", self, "change_dungeon_event_response")

	TPLG.dialogue.add_dialogue_script("tomatoes_for_sakana_entry", self)
	TPLG.dialogue.add_dialogue_script("tomatoes_for_sakana_exit", self)
	TPLG.dialogue.add_dialogue_script("pickup_yorks_hearts_entry", self)
	TPLG.dialogue.add_dialogue_script("pickup_yorks_hearts_exit", self)
	TPLG.dialogue.add_dialogue_script("say_hi_to_sakana_exit", self)
	TPLG.dialogue.add_dialogue_script("say_hi_to_baph_exit", self)
	TPLG.dialogue.add_dialogue_script("catch_gil_a_fish_exit", self)
	TPLG.dialogue.add_dialogue_script("catch_gil_a_fish_entry", self)

	finish_intro_mission_as_needed()

	baph_setup()

	reload_data_and_redraw()


func _exit_tree():
	RealmEvent.disconnect("realm_join", self, "realm_join_event_response")
	RealmEvent.disconnect("change_dungeon", self, "change_dungeon_event_response")

	TPLG.dialogue.remove_dialogue_script("tomatoes_for_sakana_entry")
	TPLG.dialogue.remove_dialogue_script("tomatoes_for_sakana_exit")
	TPLG.dialogue.remove_dialogue_script("pickup_yorks_hearts_entry")
	TPLG.dialogue.remove_dialogue_script("pickup_yorks_hearts_exit")
	TPLG.dialogue.remove_dialogue_script("say_hi_to_sakana_exit")
	TPLG.dialogue.remove_dialogue_script("say_hi_to_baph_exit")
	TPLG.dialogue.remove_dialogue_script("catch_gil_a_fish_exit")
	TPLG.dialogue.remove_dialogue_script("catch_gil_a_fish_entry")

func baph_setup():
	if ! "sayHiToBaph" in TPLG.ui.mission_list.get_current_mission_keys():
		find_node("Baph").dialogue_section = "helloPostHi"

func catch_gil_a_fish_entry():
	_start_mission("catchGilAFish")


func catch_gil_a_fish_exit():
	var passed = yield(_finish_mission("catchGilAFish", true), "completed")

	if ! passed:
		TPLG.dialogue.start("Gil", "catchGilAFishExitFailed")
	else:
		TPLG.dialogue.start("Gil", "catchGilAFishExitFinished")


func tomatoes_for_sakana_entry():
	_start_mission("tomatoesForSakana")


func tomatoes_for_sakana_exit():
	var passed = yield(_finish_mission("tomatoesForSakana", true), "completed")

	if ! passed:
		TPLG.dialogue.start("Sakana", "tomatoesForSakanaExitFailed")
	else:
		TPLG.dialogue.start("Sakana", "tomatoesForSakanaExitFinished")


func pickup_yorks_hearts_entry():
	_start_mission("pickupYorksHearts")
	var pickup_scene = ResourceLoader.load(mission_scenes["pickupYorksHearts"])
	mission_launcher_node.call_deferred("add_child", pickup_scene.instance())


func pickup_yorks_hearts_exit():
	var passed = yield(_finish_mission("pickupYorksHearts", true), "completed")

	if ! passed:
		TPLG.dialogue.start("York", "pickupYorksHeartsExitFailed")
	else:
		TPLG.dialogue.start("York", "pickupYorksHeartsExitFinished")


func say_hi_to_sakana_exit():
	yield(_finish_mission("sayHiToSakana"), "completed")

func say_hi_to_baph_exit():
	if "sayHiToBaph" in TPLG.ui.mission_list.get_current_mission_keys():
		yield(_finish_mission("sayHiToBaph"), "completed")



func finish_intro_mission_as_needed():
	if "visitTown" in TPLG.ui.mission_list.get_current_mission_keys():
		yield(_finish_mission("visitTown"), "completed")
	else:
		yield()


func setup_teleporter():
	town_teleporter = find_node("TownTeleporter")

	match TPLG.last_scene:
		"town0":
			town_teleporter.exit_enabled = false
			player_entry_node = town_teleporter
		_:  # default
			var plot: int = RealmManager.plot_map[TPLG.current_farm.user_id]
			var farm_teleporter = find_node("FarmTeleporter%s" % [plot])
			farm_teleporter.exit_enabled = false
			player_entry_node = farm_teleporter


func reload_data_and_redraw():
	for i in range(8):
		var tele = find_node("FarmTeleporter%s" % [i])
		tele.enabled = false

		find_node("MailBox%s" % [i]).hide_and_disable()

	for user_id in RealmManager.plot_map:
		var tele = find_node("FarmTeleporter%s" % RealmManager.plot_map[user_id])
		tele.enabled = true
		tele.user_id_to_join = user_id
		tele.user_avatar_to_join = RealmManager.user_id_to_avatar_map[user_id]

		find_node("MailBox%s" % [RealmManager.plot_map[user_id]]).set_user_and_show(
			tele.user_id_to_join, tele.user_avatar_to_join
		)

		if user_id == TPLG.current_farm.user_id && TPLG.last_scene != "town0":
			tele.exit_enabled = false
		else:
			tele.exit_enabled = true


func on_math_presence_event(_match_event):
	call_deferred("reload_data_and_redraw")


func realm_join_event_response(_args, _presence):
	call_deferred("reload_data_and_redraw")


func change_dungeon_event_response(_args, _userId):
	call_deferred("reload_data_and_redraw")
