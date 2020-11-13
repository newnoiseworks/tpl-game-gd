extends Node

var socket: NakamaSocket
var realm_match


func connect_socket():
	socket = Nakama.create_socket_from(SessionManager.client)
	yield(socket.connect_async(SessionManager.session), "completed")
	socket.connect("received_match_state", self, "_on_match_state")
	socket.connect("received_match_presence", self, "_on_match_presence")


func find_or_create_realm(label: String):
	var response = yield(SessionManager.rpc("find_or_create_realm", label), "completed")
	var realm_id = response.payload.replace('"', "")

	var _realm_match = yield(join_realm(realm_id), "completed")

	return _realm_match


func join_realm(realm_id: String):
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
	pass


func _on_match_presence(_presence: NakamaRTAPI.MatchPresenceEvent):
	pass
