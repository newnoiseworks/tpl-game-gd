extends "res://Scenes/Items/ItemController.gd"

# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.MovementGrid;
# using TPV.Data;
# using Godot;
# using TPV.GameEvents;
# using TPV.Utils.Network;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class AxeController : ItemController, IEquiptableItem {

#     public async void PrimaryAction() {
#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid == null) return;

#       if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().forage != FarmPermission.Can) {
#         TPV.Scenes.UI.UIController.ShowToast("You don't have permission to forage on this farm!");
#         return;
#       }

#       FarmGridData farmData = farmGrid.data;
#       Vector2 gridPosition = MovementGridController.instance.GetCurrentFarmGridTile();

#       ForageItemData tree = farmData.forageItems.list.Find((i) => {
#         return (
#           i.position == gridPosition ||
#           i.position == gridPosition - new Vector2(1, 0) ||
#           i.position == gridPosition + new Vector2(1, 0) ||
#           i.position == gridPosition + new Vector2(0, 1)
#         ) && i.type == ForageItemData.Type.Tree;
#       });

#       if (tree == null) return;

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Forage,
#         tree.position,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         ((int)ForageItemData.Type.Tree).ToString()
#       ));

#       if (
#       SessionManager.match == null &&
#       await farmData.Forage(
#         tree.position,
#         ((int)ForageItemData.Type.Tree).ToString()
#       ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
