extends PopupMenu

var user_id: String = ""

enum { ADD_FRIEND = 0, BLOCK = 1, DIRECT_MESSAGE = 2, FARM_PERMISSIONS = 3 }

var menu_item_label_map: Dictionary = {FARM_PERMISSIONS: "Farm Permissions"}


func _ready():
	for label in menu_item_label_map:
		add_item(menu_item_label_map[label], label)


func on_popup_hide():
	self.queue_free()


func on_control_pressed(item: int):
	match item:
		ADD_FRIEND:
			pass
			# add_friend()
		BLOCK:
			pass
			# block_user()
		FARM_PERMISSIONS:
			open_farm_perms()


func open_farm_perms():
	TPLG.farm_perms.popup()

# func add_friend():
#       if (await new Friend(RealmManager.userIdToUsernameMap[userId]).RequestFriendship())
#         TPV.Scenes.UI.MessageDialogController.ShowMessage("Friend request sent");
#       else
#         TPV.Scenes.UI.MessageDialogController.ShowMessage("Something went wrong, try again.");
#     }

#     private async void BlockUser() {
#       if (await new Friend(RealmManager.userIdToUsernameMap[userId]).BlockPlayer())
#         TPV.Scenes.UI.MessageDialogController.ShowMessage("Player blocked.");
#       else
#         TPV.Scenes.UI.MessageDialogController.ShowMessage("Something went wrong, try again.");
#     }
#   }
# }
