extends "res://Scenes/Items/ItemController.gd"

var user_id: String
var user_avatar_key: String
var data: Dictionary

onready var static_body: StaticBody2D = find_node("StaticBody2D")
onready var mask: int = static_body.collision_mask
onready var layer: int = static_body.collision_layer
onready var label: Label = find_node("Label")


func set_user_and_show(_user_id: String, _user_avatar_key: String):
	if user_id != user_id || user_avatar_key != _user_avatar_key:
		user_avatar_key = _user_avatar_key
		user_id = _user_id

	var profile_data = yield(
		SaveData.load("profile", SaveData.all_avatars_key, user_id), "completed"
	)

	for avatar in profile_data.avatars:
		if avatar.key == user_avatar_key:
			data = avatar

  label.text = "%s'%s Farm" % [data.name, "s" if data.name[data.name.length() - 1] != "s" else ""]

	static_body.collision_mask = mask
	static_body.collision_layer = layer
	show()


func hide_and_disable():
	static_body.collision_mask = 0
	static_body.collision_layer = 0
	hide()


func interact():
	if data.empty() || ! data.has("name"):
		return

	TPLG.dialogue.start(
		{
			"whom": "mailbox",
			"text": "%s's Farm" % data.name,
			"options": null,
			"next": null,
			"script": null,
		}
	)
