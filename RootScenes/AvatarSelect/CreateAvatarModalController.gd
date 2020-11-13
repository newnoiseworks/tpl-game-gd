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

	var data = SessionManager.profile_data
	var has_key = false

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

	data.avatars.push_back(avatar_data)

	yield(SaveData.save(data, "profile", SaveData.all_avatars_key), "completed")

#       await SessionManager.client.RpcAsync(
#         SessionManager.session,
#         "user.on_registration",
#         avatarData.key
#       );

#       await SessionManager.SetCurrentCharacter(avatarData);
#       await RealmManager.FindOrCreateRealm("town0-realm");

#       GetTree().ChangeScene("res://RootScenes/BaseViewports/BaseViewports.tscn");
#     }
#   }
# }
