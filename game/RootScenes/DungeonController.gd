extends "res://RootScenes/RootController.gd"

export var dungeon: String

var user_ids: Array = []
# var player_scene: PackedScene = ResourceLoader.load("res://Scenes/Character/Farmer/Player.tscn")
var farmer_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/Character/Farmer/Farmer.tscn", "", true
)


func _ready():
	if no_children():
		return

	call_deferred("add_child", MoveTarget)

	call_deferred("_add_player_to_scene")
	user_ids.append(SessionManager.session.user_id)

	MatchEvent.connect("match_join", self, "_handle_match_join_event")
	MatchManager.socket.connect("received_match_presence", self, "_on_match_presence")

	if self.has_method("setup_teleporter"):
		call("setup_teleporter")

	if dungeon != null && dungeon != '':
		yield(_join_dungeon(), "completed")


func _exit_tree():
	if MatchManager.game_match != null:
		MatchManager.socket.disconnect("received_match_presence", self, "_on_match_presence")
		MatchEvent.disconnect("match_join", self, "_handle_match_join_event")
		MatchManager.game_match = null


func _join_dungeon():
	yield(MatchManager.find_or_create_match(dungeon, player_entry_node.position), "completed")
	TPLG.ui.hide_loading_dialog()


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

		_setup_networked_player_for_screen(user_id, args)


func _setup_networked_player_for_screen(user_id, args):
	var starting_position: Vector2 = player_entry_node.position

	if user_id in args.positions.keys() && "x" in args.positions[user_id]:
		starting_position = Vector2(
			float(args.positions[user_id].x), float(args.positions[user_id].y)
		)

	var movement_target: Vector2 = starting_position

	if args.movementTargets.keys().has(user_id) && args.movementTargets[user_id].has("x"):
		movement_target = Vector2(args.movementTargets[user_id].x, args.movementTargets[user_id].y)

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

	environment_items.add_child(player_node)
