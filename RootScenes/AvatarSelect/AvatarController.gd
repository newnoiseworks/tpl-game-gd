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
	SaveData.current_avatar_key = avatar_data.key
	SessionManager.set_current_avatar(avatar_data)
	Player.avatar_data = avatar_data

	yield(RealmManager.find_or_create_realm("town0-realm"), "completed")

	TPLG.base_change_scene("res://RootScenes/RewriteTest.tscn")
