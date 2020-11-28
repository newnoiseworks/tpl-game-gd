extends "res://Scenes/Items/ItemController.gd"

# using TPV.Utils;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.MovementGrid;
# using TPV.Data;
# using Godot;
# using TPV.GameEvents;
# using TPV.Utils.Network;
# using Nakama.TinyJson;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class PickaxeController : ItemController, IEquiptableItem {

#     public void PrimaryAction() {
#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid == null) return;

#       FarmGridData farmData = farmGrid.data;
#       Vector2 gridPosition = MovementGridController.instance.GetCurrentFarmGridTile();

#       ForageItemData stone = farmData.forageItems.list.Find((i) => { return i.position == gridPosition && i.type == ForageItemData.Type.Stone; });

#       if (stone != null)
#         if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions(SessionManager.GetUserId()).forage != FarmPermission.Can)
#           TPV.Scenes.UI.UIController.ShowToast("You don't have permission to forage on this farm!");
#         else
#           SendForageAction(gridPosition, farmData);
#       else if (farmGrid.IsTileTilled(gridPosition) && farmGrid.HasFarmItem(gridPosition) == false)
#         if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().till != FarmPermission.Can)
#           TPV.Scenes.UI.UIController.ShowToast("You don't have permission to till soil on this farm!");
#         else
#           SendDetillAction(gridPosition, farmData);
#     }

#     public async void SendDetillAction(Vector2 gridPosition, FarmGridData farmData) {
#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Detill,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Detill(
#           gridPosition
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }

#     public async void SendForageAction(Vector2 gridPosition, FarmGridData farmData) {
#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Forage,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         ((int)ForageItemData.Type.Stone).ToString()
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Forage(
#           gridPosition,
#           ((int)ForageItemData.Type.Stone).ToString()
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
