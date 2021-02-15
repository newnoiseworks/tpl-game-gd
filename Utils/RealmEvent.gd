extends Node

enum { REALM_JOIN = 0, CHANGE_DUNGEON = 1, WALLET_UPDATE = 2, WEATHER_CHANGE = 3 }

signal realm_join(state, presence)
signal change_dungeon(state, presence)
signal wallet_update(state, presence)
signal weather_change(state, presence)

var signal_map = {
	REALM_JOIN: "realm_join",
	CHANGE_DUNGEON: "change_dungeon",
	WALLET_UPDATE: "wallet_update",
	WEATHER_CHANGE: "weather_change"
}


func handle_match_state_update(state: NakamaRTAPI.MatchData):
	if state.presence != null && state.presence.user_id == SessionManager.session.user_id:
		return

	match state.op_code:
		REALM_JOIN:
			emit_signal("realm_join", state.data, state.presence if state.presence != null else {})
		CHANGE_DUNGEON:
			emit_signal(
				"change_dungeon", state.data, state.presence if state.presence != null else {}
			)
		WALLET_UPDATE:
			emit_signal(
				"wallet_update", state.data, state.presence if state.presence != null else {}
			)
		WEATHER_CHANGE:
			emit_signal(
				"weather_change", state.data, state.presence if state.presence != null else {}
			)


func emit(op_code: int, payload: String):
	var event: String = signal_map[op_code]
	emit_signal(event, payload, {"user_id": SessionManager.session.user_id})
	RealmManager.socket.send_match_state_async(RealmManager.realm_match.match_id, op_code, payload)


func change_dungeon(payload):
	emit(CHANGE_DUNGEON, JSON.print(payload))
