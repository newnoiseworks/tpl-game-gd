extends "res://RootScenes/RootController.gd"

export var dungeon: String

var user_ids: Array = []
# var player_scene: PackedScene = ResourceLoader.load("res://Scenes/Character/Farmer/Player.tscn")
# var farmer_scene: PackedScene = ResourceLoader.load("res://Scenes/Character/Farmer/Farmer.tscn")
var base_viewports_scene = preload("res://RootScenes/BaseViewports/BaseViewports.tscn")

onready var player_entry_node: Node2D = find_node("PlayerEntry")


func _ready():
	if SessionManager.session == null:
		call_deferred("_login_with_dev_creds")
		return

	call("add_child", MoveTarget)

	_add_player_to_scene()
	user_ids.append(SessionManager.session.user_id)

	if dungeon != null && dungeon != '':
		yield(_join_dungeon(), "completed")

	MatchManager.socket.connect("received_match_presence", self, "_on_match_presence")
	MatchEvent.connect("match_join", self, "_handle_match_join_event")


func _exit_tree():
	if MatchManager.game_match != null:
		yield(MatchManager.leave_match(), "completed")
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
	TPLG.call_deferred("base_change_scene", filename)


func _join_dungeon():
#       UIController.ShowLoadingDialog();
	yield(MatchManager.find_or_create_match(dungeon, player_entry_node.position), "completed")
#       UIController.HideLoadingDialog();
	pass


func _add_player_to_scene():
	Player.position = player_entry_node.position
	Player.name = SessionManager.session.user_id
	Player.user_id = SessionManager.session.user_id
	find_node("EnvironmentItems").call("add_child", Player)
	Player.restrict_camera_to_tile_map(find_node("Ground"))
	get_tree().root.emit_signal("size_changed")
	Player.set_idle()
	pass


#       playerNode.avatarData = SessionManager.currentCharacter;

#       SessionManager.player = playerNode;


func _on_match_presence(match_event: NakamaRTAPI.MatchPresenceEvent):
	for presence in match_event.leaves:
		user_ids.erase(presence.user_id)
		find_node(presence.user_id, true, false).queue_free()


func handle_match_join_event(args):
	pass
#       foreach (KeyValuePair<string, int> pair in args.plotMap) {
#         string userId = pair.Key;

#         if (userIds.Contains(userId)) continue;

#         Friend friend = SessionManager.friends.Find(f => f.id == userId);

#         if (friend != null && friend.apiFriend.State == 3) continue;

#         userIds.Add(userId);
#         userIdToAvatarMap.Add(userId, args.avatarMap[userId]);

#         Vector2 startingPosition = args.positions.ContainsKey(userId) ? args.positions[userId] : playerEntryNode.Position;

#         CallDeferred(
#           "AddNetworkedPlayerToScene",
#           userId,
#           args.avatarMap[userId],
#           startingPosition,
#           args.movementTargets.ContainsKey(userId) ? args.movementTargets[userId] : startingPosition
#         );
#       }
#     }

#     private async void AddNetworkedPlayerToScene(string userId, string avatarKey, Vector2 position, Vector2 movementTarget) {
#       FarmerController playerNode = (FarmerController)farmerScene.Instance();

#       ProfileData profileData = new ProfileData(userId);
#       await profileData.Load();

#       playerNode.avatarData = profileData.avatars.list.Find((a) => a.key == avatarKey);
#       playerNode.username = playerNode.avatarData.name;
#       playerNode.Name = userId;
#       playerNode.userId = userId;
#       playerNode.Position = position;
#       playerNode.positionFromServer = position;
#       playerNode.movementTarget = movementTarget;
#       playerNode.serverDerivedPosition = true;

#       FindNode("EnvironmentItems").AddChild(playerNode);
#     }
# }
