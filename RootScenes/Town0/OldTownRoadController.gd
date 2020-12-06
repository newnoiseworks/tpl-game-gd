extends "res://RootScenes/DungeonController.gd"

var player_context_menu_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/PlayerContextMenu.tscn"
)

var town_teleporter


func _ready():
	setup_teleporter()

	RealmEvent.connect("realm_join", self, "realm_join_event_response")
	RealmEvent.connect("change_dungeon", self, "change_dungeon_event_response")

	reload_data_and_redraw()


func _exit_tree():
	RealmEvent.disconnect("realm_join", self, "realm_join_event_response")
	RealmEvent.disconnect("change_dungeon", self, "change_dungeon_event_response")


func setup_teleporter():
	town_teleporter = find_node("TownTeleporter")

	match TPLG.last_scene:
		"town0":
			town_teleporter.exit_enabled = false
			player_entry_node = town_teleporter
		_:  # default
			var plot: int = RealmManager.plot_map[SessionManager.session.user_id]
			var farm_teleporter = find_node("FarmTeleporter%s" % [plot])
			farm_teleporter.exit_enabled = false
			player_entry_node = farm_teleporter


func reload_data_and_redraw():
	for i in range(8):
		var tele = find_node("FarmTeleporter%s" % [i])
		tele.enabled = false

		find_node("MailBox%s" % [i]).hide_and_disable()

	for user_id in RealmManager.plot_map:
		var tele = find_node("FarmTeleporter%s" % RealmManager.plot_map[user_id])
		tele.enabled = true
		tele.user_id_to_join = user_id
		tele.user_avatar_to_join = RealmManager.user_id_to_avatar_map[user_id]

		find_node("MailBox%s" % [RealmManager.plot_map[user_id]]).set_user_and_show(
			tele.user_id_to_join, tele.user_avatar_to_join
		)

		if user_id == TPLG.current_farm.user_id && TPLG.last_scene != "town0":
			tele.exit_enabled = false
		else:
			tele.exit_enabled = true


func on_math_presence_event(_match_event):
	call_deferred("reload_data_and_redraw")


func realm_join_event_response(_args, _presence):
	call_deferred("reload_data_and_redraw")


func change_dungeon_event_response(_args, _userId):
	call_deferred("reload_data_and_redraw")
