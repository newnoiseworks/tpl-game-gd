extends ConfirmationDialog

var avatar_name: String

onready var color_swatch: ColorRect = find_node("ColorRect")
onready var outfit_manager = find_node("CreateAvatarOutfitManager")


func avatar_name_updated(text: String):
	avatar_name = text


func on_color_rect_click(base_type: int):
	outfit_manager.set_base_type(base_type)


func confirmed():
	if avatar_name == null || avatar_name == "":
		return

	var data = SessionManager.profile_data if SessionManager.profile_data else {}
	var has_key = false

	if data.has("avatars"):
		for avatar in data.avatars:
			if avatar.key == avatar_name:
				has_key = true

	if has_key:
		TPLG.show_message("Can't use that name, please try another.")
		return

	var avatar_data = {
		"name": avatar_name,
		"key": avatar_name,
		"hairType": outfit_manager.mannequin.avatar_data.hairType,
		"topType": outfit_manager.mannequin.avatar_data.topType,
		"bottomType": outfit_manager.mannequin.avatar_data.bottomType,
		"baseType": outfit_manager.mannequin.avatar_data.baseType
	}

	if ! data.has("avatars"):
		data.avatars = []

	data.avatars.append(avatar_data)

	print(JSON.print(data))

	yield(SaveData.save(data, "profile", SaveData.all_avatars_key), "completed")

	yield(SessionManager.rpc_async("user.on_registration", avatar_data.key), "completed")

	SessionManager.set_current_avatar(avatar_data)
	yield(RealmManager.find_or_create_realm("town0-realm"), "completed")

	TPLG.base_change_scene("res://RootScenes/RewriteTest.tscn")
	TPLG.call_deferred("set_ui_scene")
