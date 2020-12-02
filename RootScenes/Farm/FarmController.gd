extends "res://RootScenes/DungeonController.gd"

var user_id_to_join: String
var user_avatar_to_join: String
var join_match_on_ready: bool = true

var farm_grid_scene: PackedScene = ResourceLoader.load("res://Scenes/FarmGrid/FarmGrid.tscn")

var farm_grids = []
var permissions_data = {}


func _ready():
	if user_id_to_join == "":
		user_id_to_join = SessionManager.session.user_id

	if user_avatar_to_join == "":
		user_avatar_to_join = SaveData.current_avatar_key

	TPLG.current_farm.user_id = user_id_to_join
	TPLG.current_farm.user_avatar = user_avatar_to_join

	RealmEvent.connect("change_dungeon", self, "change_dungeon_handler")
	MatchEvent.connect("farm_permission_update", self, "farm_permissions_update_event_callback")
	setup_farm_grids()
	setup_player_entry()

	Player.lock_movement = true
	TPLG.ui.show_loading_dialog()
	permissions_data = yield(
		SaveData.load("town0FarmGridPermissions", user_avatar_to_join, user_id_to_join), "completed"
	)
	yield(load_farm(), "completed")
	TPLG.ui.hide_loading_dialog()
	Player.lock_movement = false


func _exit_tree():
	RealmEvent.disconnect("change_dungeon", self, "change_dungeon_handler")
	MatchEvent.disconnect("farm_permission_update", self, "farm_permissions_update_event_callback")
	join_match_on_ready = false


func farm_permissions_update_event_callback(_args: Dictionary, _user_id: String):
	permissions_data = yield(
		SaveData.load("town0FarmGridPermissions", user_avatar_to_join, user_id_to_join), "completed"
	)

	for farm_grid in farm_grids:
		farm_grid.farm_permissions = permissions_data


func load_farm():
	for farm_grid in farm_grids:
		yield(farm_grid.load_farm(user_id_to_join, user_avatar_to_join), "completed")
		farm_grid.farm_permissions = permissions_data
		farm_grid.draw_plants_from_data()

	if join_match_on_ready || are_other_people_on_farm():
		print("Joining a match for this farm...")
		yield(start_match(user_id_to_join, user_avatar_to_join), "completed")
		join_match_on_ready = false
	else:
		RealmEvent.change_dungeon({"dungeon": "%s's Farm" % [user_avatar_to_join]})


func change_dungeon_handler(_args, _presence):
	call_deferred("load_match_if_necessary")


func load_match_if_necessary():
	if MatchManager.game_match != null:
		return

	if are_other_people_on_farm():
		yield(start_match(user_id_to_join, user_avatar_to_join), "completed")


func start_match(user_id: String, avatar: String):
	return yield(
		MatchManager.find_or_create_match(get_farm_match_label(user_id, avatar), Player.position),
		"completed"
	)


func are_other_people_on_farm():
	var other_players_on_farm = false

	for user_id in RealmManager.user_id_to_dungeon_map:
		var dungeon = RealmManager.user_id_to_dungeon_map[user_id]

		if (
			dungeon == "%s's Farm" % [user_avatar_to_join]
			&& user_id != SessionManager.session.user_id
		):
			other_players_on_farm = true
			break

	return other_players_on_farm


func setup_farm_grids():
	farm_grids.clear()
	TPLG.current_farm_grids.clear()

	for x in range(5):
		for y in range(5):
			var farm_grid = find_node("FarmGrid-%s-%s" % [x, y])
			if farm_grid != null:
				farm_grids.append(farm_grid)
				TPLG.current_farm_grids.append(farm_grid)


func setup_player_entry():
	var town_entrance_left = find_node("LeftEntry")
	var town_entrance_top = find_node("TopEntry")
	var house_entrance = find_node("PlayerEntry")

	var town_entrance: Node2D

	var top_entry_plots = [0, 2, 4, 6]

	if top_entry_plots.has(RealmManager.plot_map[user_id_to_join]):
		town_entrance = town_entrance_top
	else:
		town_entrance = town_entrance_left

	town_entrance.show()

	if TPLG.last_scene == "town0OldTownRoad":
		player_entry_node = town_entrance
		town_entrance.find_node("Teleporter").exit_enabled = false
	else:
		player_entry_node = house_entrance


func create_private_farm_match():
	return yield(
		MatchManager.find_or_create_dungeon(
			get_farm_match_label(SessionManager.session.user_id, SaveData.current_avatar_key),
			Player.position
		),
		"completed"
	)


func get_farm_match_label(user_id: String, avatar_key: String):
	return "town0UserFarm//%s//%s" % [user_id, avatar_key]


func lake_body_enter(body):
	if body == MoveTarget:
		Player.is_over_water_source = true


func lake_body_exit(body):
	if body == MoveTarget:
		Player.is_over_water_source = false
