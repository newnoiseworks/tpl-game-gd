extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.MovementGrid;
# using TPV.Data;
# using TPV.GameEvents;
# using TPV.Utils.Network;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class TillerController : ItemController, IEquiptableItem {

#     public void PrimaryAction() {
#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid == null) return;

#       if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().till != FarmPermission.Can) {
#         TPV.Scenes.UI.UIController.ShowToast("You don't have permission to till soil on this farm!");
#         return;
#       }

#       FarmGridData farmData = farmGrid.data;
#       Vector2 gridPosition = MovementGridController.instance.GetCurrentFarmGridTile();
#       string tileName = farmGrid.GetGroundMapTilenameFromPosition(gridPosition);

#       if ((tileName != null && tileName.Contains("Environment/Dirt/Dirt") == false) || farmGrid.HasFarmItem(gridPosition)) return;

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Till,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName
#       ));

#       if (SessionManager.match == null) TillRPCMethod(farmData, gridPosition);
#     }

#     public async void TillRPCMethod(FarmGridData farmData, Vector2 gridPosition) {
#       bool tillOk = await farmData.Till(
#         gridPosition
#       );

#       if (tillOk == false)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
