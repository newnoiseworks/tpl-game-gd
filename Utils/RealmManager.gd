extends Node

var socket: NakamaSocket
var realm_match: NakamaRTAPI.Match

var user_ids: Array = []
var user_id_to_avatar_map: Dictionary = {}
var user_id_to_dungeon_map: Dictionary = {}
var user_id_to_username_map: Dictionary = {}
var plot_map: Dictionary = {}


func connect_socket():
	socket = Nakama.create_socket_from(SessionManager.client)
	yield(socket.connect_async(SessionManager.session), "completed")
	socket.connect("received_match_state", self, "_on_match_state")
	socket.connect("received_match_presence", self, "_on_match_presence")
	RealmEvent.connect("realm_join", self, "_realm_join_event_response")
	RealmEvent.connect("change_dungeon", self, "_change_dungeon_event_response")


func find_or_create_realm(label: String):
	var response = yield(SessionManager.rpc("find_or_create_realm", label), "completed")
	var realm_id = response.payload.replace('"', "")

	var _realm_match = yield(_join_realm(realm_id), "completed")

	return _realm_match


func _join_realm(realm_id: String) -> NakamaRTAPI.Match:
	realm_match = yield(
		socket.join_match_async(
			realm_id,
			{
				"username": SessionManager.session.username,
				"avatarName": SessionManager.current_avatar.name
			}
		),
		"completed"
	)

	if realm_match.is_exception():
		print("An error occured: %s" % realm_match)

	return realm_match


func _on_match_state(_state: NakamaRTAPI.MatchData):
	RealmEvent.handle_match_state_update(_state)


func _on_match_presence(event: NakamaRTAPI.MatchPresenceEvent):
	for presence in event.leaves:
		user_ids.erase(presence.user_id)
		user_id_to_avatar_map.erase(presence.user_id)
		user_id_to_username_map.erase(presence.user_id)
		plot_map.erase(presence.user_id)


func leave_realm():
	if realm_match != null:
		yield(socket.leave_match_async(realm_match.match_id), "completed")

	realm_match = null
	_destroy_realm_session()


func _destroy_realm_session():
	socket.disconnect("received_match_state", self, "_on_match_state")
	socket.disconnect("received_match_presence", self, "_on_match_presence")
	RealmEvent.disconnect("realm_join", self, "_realm_join_event_response")
	RealmEvent.disconnect("change_dungeon", self, "_change_dungeon_event_response")
	# FarmController.userIdToJoin = null;
	# FarmController.userAvatarToJoin = null;


func _realm_join_event_response(state: NakamaRTAPI.MatchData):
	var args = parse_json(state.data)

	user_id_to_avatar_map = args.avatarMap
	user_id_to_dungeon_map = args.dungeonMap
	user_id_to_username_map = args.usernameMap

	plot_map = args.plotMap
	user_ids = []

	for key in user_id_to_avatar_map:
		user_ids.append(key)


func _change_dungeon_event_response(state: NakamaRTAPI.MatchData):
	var args = JSON.parse(state.data)
	user_id_to_dungeon_map[state.presence.user_id] = args.dungeon
