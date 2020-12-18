extends TextureButton

var avatar_data

onready var name_label: Label = $Name
onready var farmer = $Farmer


func set_data(_avatar_data):
	avatar_data = _avatar_data

	name_label.text = avatar_data.name
	farmer.avatar_data = avatar_data
	farmer.set_idle()


func on_pressed():
	SessionManager.set_current_avatar(avatar_data)
	yield(SessionManager.load_mission_data(), "completed")
	yield(RealmManager.find_or_create_realm("town0-realm"), "completed")

	# TPLG.base_change_scene("res://RootScenes/RewriteTest.tscn")
	TPLG.set_ui_scene()
	TPLG.base_change_scene(
		"res://RootScenes/Farm/Farm.tscn",
		{
			"user_id_to_join": SessionManager.session.user_id,
			"user_avatar_to_join": avatar_data.key,
			"join_match_on_ready": true
		}
	)
