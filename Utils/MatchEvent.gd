extends Node

enum {
	MOVEMENT = 0,
	FARMING = 1,
	FARM_PERMISSION_UPDATE = 2,
	DATA_RESET = 4,
	AVATAR_UPDATE = 5,
	MATCH_JOIN = 6
}

signal movement(state)
signal farming(state)
signal farm_permission_update(state)
signal data_reset(state)
signal avatar_update(state)
signal match_join(state)

var signal_map = {
	MOVEMENT: "movement",
	FARMING: "farming",
	FARM_PERMISSION_UPDATE: "farm_permission_update",
	DATA_RESET: "data_reset",
	AVATAR_UPDATE: "avatar_update",
	MATCH_JOIN: "match_join"
}


func handle_match_state_update(state: NakamaRTAPI.MatchData):
	if state.presence != null && state.presence.user_id == SessionManager.session.user_id:
		return

	match state.op_code:
		MOVEMENT:
			emit_signal("movement", state)
		FARMING:
			emit_signal("farming", state)
		FARM_PERMISSION_UPDATE:
			emit_signal("farm_permission_update", state)
		DATA_RESET:
			emit_signal("data_reset", state)
		AVATAR_UPDATE:
			emit_signal("avatar_update", state)
		MATCH_JOIN:
			emit_signal("match_join", state)


func emit(op_code: int, payload: String):
	var event: String = signal_map[op_code]
	emit_signal(event, {"data": payload, "presence": {"user_id": SessionManager.session.user_id}})
	MatchManager.socket.send_match_state_async(MatchManager.game_match.match_id, op_code, payload)


func movement(payload):
	emit(MOVEMENT, JSON.print(payload))


func farming(payload):
	emit(FARMING, JSON.print(payload))


func farm_permission_update(payload):
	emit(FARM_PERMISSION_UPDATE, JSON.print(payload))


func avatar_update(payload):
	emit(AVATAR_UPDATE, JSON.print(payload))


func match_join(payload):
	emit(MATCH_JOIN, JSON.print(payload))
