extends "res://RootScenes/RootController.gd"

export var dungeon: String

var user_ids: Array = []
# var player_scene: PackedScene = ResourceLoader.load("res://Scenes/Character/Farmer/Player.tscn")
var farmer_scene: PackedScene = ResourceLoader.load("res://Scenes/Character/Farmer/Farmer.tscn")
var base_viewports_scene = preload("res://RootScenes/BaseViewports/BaseViewports.tscn")

onready var player_entry_node: Node2D = find_node("PlayerEntry")


func _ready():
	if SessionManager.session == null:
		call_deferred("_login_with_dev_creds")
		return

	call_deferred("add_child", MoveTarget)

	call_deferred("_add_player_to_scene")
	user_ids.append(SessionManager.session.user_id)

	MatchEvent.connect("match_join", self, "_handle_match_join_event")
	MatchManager.socket.connect("received_match_presence", self, "_on_match_presence")

	if dungeon != null && dungeon != '':
		yield(_join_dungeon(), "completed")


func _exit_tree():
	if MatchManager.game_match != null:
		MatchManager.socket.disconnect("received_match_presence", self, "_on_match_presence")
		MatchEvent.disconnect("match_join", self, "_handle_match_join_event")


func _login_with_dev_creds():
	yield(SessionManager.login("wow@wow.com", "password"), "completed")
	SaveData.current_avatar_key = "Wowsers"

	for avatar in SessionManager.profile_data.avatars:
		if avatar.key == SaveData.current_avatar_key:
			SessionManager.set_current_avatar(avatar)
			Player.avatar_data = avatar

	get_parent().add_child(base_viewports_scene.instance())
	get_parent().remove_child(self)
	yield(RealmManager.find_or_create_realm("town0-realm"), "completed")
	TPLG.set_ui_scene()
	TPLG.call_deferred("base_change_scene", filename)


func _join_dungeon():
	yield(MatchManager.find_or_create_match(dungeon, player_entry_node.position), "completed")
	TPLG.ui.hide_loading_dialog()


func _add_player_to_scene():
	Player.position = player_entry_node.position
	Player.name = SessionManager.session.user_id
	Player.user_id = SessionManager.session.user_id
	find_node("EnvironmentItems").call_deferred("add_child", Player)
	Player.restrict_camera_to_tile_map(find_node("Ground"))
	get_tree().root.emit_signal("size_changed")
	Player.set_idle()


func _on_match_presence(match_event: NakamaRTAPI.MatchPresenceEvent):
	for presence in match_event.leaves:
		user_ids.erase(presence.user_id)
		var user_to_erase = find_node(presence.user_id, true, false)
		if user_to_erase != null:
			user_to_erase.queue_free()


func _handle_match_join_event(data, _presence):
	var args = JSON.parse(data).result

	for user_id in args.plotMap.keys():
		if user_ids.has(user_id):
			continue

		user_ids.append(user_id)

		var starting_position: Vector2

		if args.positions.keys().has(user_id) && args.positions[user_id].has("x"):
			starting_position = Vector2(args.positions[user_id].x, args.positions[user_id].y)
		else:
			starting_position = player_entry_node.position

		var movement_target: Vector2

		if args.movementTargets.keys().has(user_id) && args.movementTargets[user_id].has("x"):
			movement_target = Vector2(
				args.movementTargets[user_id].x, args.movementTargets[user_id].y
			)
		else:
			movement_target = starting_position

		call_deferred(
			"add_networked_player_to_scene",
			user_id,
			args.avatarMap[user_id],
			starting_position,
			movement_target
		)


func add_networked_player_to_scene(
	user_id: String, avatar_key: String, position: Vector2, movement_target: Vector2
):
	var player_node = farmer_scene.instance()

	var profile_data = yield(
		SaveData.load("profile", SaveData.all_avatars_key, user_id), "completed"
	)

	var avatar_data

	for avatar in profile_data.avatars:
		if avatar.key == avatar_key:
			avatar_data = avatar

	player_node.avatar_data = avatar_data
	player_node.username = avatar_data.name
	player_node.name = user_id
	player_node.user_id = user_id
	player_node.position = position
	player_node.position_from_server = position
	player_node.movement_target = movement_target
	player_node.server_derived_position = true

	find_node("EnvironmentItems").add_child(player_node)
