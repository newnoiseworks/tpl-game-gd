extends Control

var player_context_menu_scene = ResourceLoader.load("res://Scenes/UI/PlayerContextMenu.tscn")
var profile_map = {}
var avatar_map = {}
var item_list = {}

var users_listed = []


func _ready():
	item_list = find_node("ItemList")
	RealmManager.socket.connect("received_match_presence", self, "on_match_presence_event")
	RealmEvent.connect("change_dungeon", self, "change_dungeon_event_response")


func _exit_tree():
	RealmManager.socket.disconnect("received_match_presence", self, "on_match_presence_event")
	RealmEvent.disconnect("change_dungeon", self, "change_dungeon_event_response")


func ready_on_popup():
	profile_map.clear()
	reload_data_and_redraw()


func reload_data_and_redraw():
	users_listed.clear()

	for user_id in RealmManager.user_ids:
		if profile_map.has(user_id):
			continue

		var data = yield(SaveData.load("profile", SaveData.all_avatars_key, user_id), "completed")

		# NOTE: Kind of jank, just in case another profile call finishes first from another event
		if profile_map.has(user_id):
			continue

		profile_map[user_id] = data

	item_list.clear()
	avatar_map.clear()

	for user_id in RealmManager.user_id_to_avatar_map.keys():
		var avatar_key = RealmManager.user_id_to_avatar_map[user_id]
		var data = profile_map[avatar_key]
		users_listed.insert(user_id)

		var avatar

		for _avatar in data.avatars:
			if _avatar.key == avatar_key:
				avatar = _avatar

		avatar_map.insert(user_id, avatar)

		var dungeon: String = (
			RealmManager.user_id_to_dungeon_map[user_id]
			if RealmManager.user_id_to_dungeon_map.has(user_id)
			else ""
		)

		var username: String = RealmManager.user_id_to_username_map[user_id]
		item_list.add_item("%s (%s) - %s" % [avatar.name, username, dungeon])


func on_match_presence():
	call_deferred("reload_data_and_redraw")


func change_dungeon_event_response():
	call_deferred("reload_data_and_redraw")


func on_item_list_rmb_click(index: int, at_position: Vector2):
	var user_id = users_listed[index]
	if user_id == SessionManager.session.user_id:
		return

	var context_menu = player_context_menu_scene.instance()
	self.add_child(context_menu)
	context_menu.user_id = user_id
	context_menu.popup_(Rect2(get_global_rect().position + at_position, context_menu.rect_size))
