extends PopupMenu

# using System.Collections.Generic;
# using Godot;
# using TPV.Autoload;
# using TPV.Scenes.UI.FarmPermissionsUI;
# using TPV.Utils.Network;

# namespace TPV.Scenes.UI {
#   public class PlayerContextMenuController : PopupMenu {

#     public string userId = "";

#     private enum MenuItem {
#       AddFriend = 0,
#       Block = 1,
#       DirectMessage = 2,
#       FarmPermissions = 3
#     }

#     private static Dictionary<MenuItem, string> menuItemLabelMap = new Dictionary<MenuItem, string>() {
#     { MenuItem.AddFriend, "Add Friend" },
#     { MenuItem.Block, "Block" },
#     { MenuItem.DirectMessage, "Direct Message" },
#     { MenuItem.FarmPermissions, "Farm Permissions" }
#   };

#     public override void _Ready() {
#       foreach (KeyValuePair<MenuItem, string> label in menuItemLabelMap)
#         AddItem(label.Value, (int)label.Key);
#     }

#     private void OnPopupHide() {
#       NodeManager.ScheduleFree(this);
#     }

#     private void OnControlPressed(int id) {
#       MenuItem item = (MenuItem)id;

#       switch (item) {
#         case MenuItem.AddFriend:
#           AddFriend();
#           break;
#         case MenuItem.Block:
#           BlockUser();
#           break;
#         case MenuItem.FarmPermissions:
#           OpenFarmPerms();
#           break;
#       }
#     }

#     private void OpenFarmPerms() {
#       FarmPermissionsController.instance.Popup(userId);
#     }

#     private async void AddFriend() {
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
