extends Node

var session: NakamaSession

var profile_data

var current_avatar

onready var client := Nakama.create_client(
	TPLG.nakama_key, TPLG.nakama_host, TPLG.nakama_port, "https" if TPLG.nakama_secure else "http"
)


func set_current_avatar(avatar_data):
	current_avatar = avatar_data


func get_profile_data():
	profile_data = yield(SaveData.load("profile", SaveData.all_avatars_key), "completed")

	return profile_data


func login(email: String, password: String):
	session = yield(client.authenticate_email_async(email, password), "completed")
	yield(post_auth(), "completed")

	return session


func sign_up(email: String, username: String, password: String):
	session = yield(client.authenticate_email_async(email, password, username, true), "completed")
	yield(post_auth(), "completed")

	return session


func rpc(uri: String, payload: String = ""):
	return yield(client.rpc_async(session, uri, payload), "completed")


func post_auth():
	yield(RealmManager.connect_socket(), "completed")
	yield(MatchManager.connect_socket(), "completed")
	yield(get_profile_data(), "completed")
