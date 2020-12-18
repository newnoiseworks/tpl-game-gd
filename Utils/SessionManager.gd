extends Node

var session: NakamaSession

var profile_data

var mission_data

var current_avatar

var api_account: NakamaAPI.ApiAccount

var wallet_data

onready var client = Nakama.create_client(
	TPLG.nakama_key, TPLG.nakama_host, TPLG.nakama_port, "https" if TPLG.nakama_secure else "http"
)


func rpc_async(uri: String, payload: String = "") -> NakamaAPI.ApiRpc:
	return yield(client.rpc_async(session, uri, payload), "completed")


func set_current_avatar(avatar_data):
	current_avatar = avatar_data
	SaveData.current_avatar_key = avatar_data.key
	Player.user_id = session.user_id
	Player.avatar_data = avatar_data


func load_mission_data():
	mission_data = yield(SaveData.load("missionData"), "completed")


func get_profile_data():
	profile_data = yield(SaveData.load("profile", SaveData.all_avatars_key), "completed")

	return profile_data


func login(email: String, password: String):
	if client == null:
		client = Nakama.create_client(
			TPLG.nakama_key,
			TPLG.nakama_host,
			TPLG.nakama_port,
			"https" if TPLG.nakama_secure else "http"
		)

	session = yield(client.authenticate_email_async(email, password), "completed")
	yield(post_auth(), "completed")

	return session


func signup(email: String, username: String, password: String):
	if client == null:
		client = Nakama.create_client(
			TPLG.nakama_key,
			TPLG.nakama_host,
			TPLG.nakama_port,
			"https" if TPLG.nakama_secure else "http"
		)

	session = yield(client.authenticate_email_async(email, password, username, true), "completed")
	yield(post_auth(), "completed")

	return session


func post_auth():
	yield(RealmManager.connect_socket(), "completed")
	yield(MatchManager.connect_socket(), "completed")
	yield(get_profile_data(), "completed")
	yield(load_api_account(), "completed")
	yield(load_time_from_server_and_start_game_time(), "completed")


func load_time_from_server_and_start_game_time():
	var time: NakamaAPI.ApiRpc = yield(rpc_async("get_server_time"), "completed")
	var pp = time.payload
	GameTime.start_timer(int(pp))


func load_api_account():
	api_account = yield(client.get_account_async(session), "completed")
	wallet_data = JSON.parse(api_account.wallet).result


func get_corpus_coin():
	return wallet_data["CorpusCoin-" + current_avatar.key]


func get_community_coin():
	return wallet_data["CommunityCoin-" + current_avatar.key]
