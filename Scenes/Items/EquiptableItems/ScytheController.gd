extends "res://Scenes/Items/ItemController.gd"

# using TPV.Utils;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.MovementGrid;
# using TPV.Data;
# using Godot;
# using TPV.GameEvents;
# using TPV.Utils.Network;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class ScytheController : ItemController, IEquiptableItem {

#     public async void PrimaryAction() {
#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid == null) return;

#       if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().forage != FarmPermission.Can)
#         TPV.Scenes.UI.UIController.ShowToast("You don't have permission to forage on this farm!");

#       FarmGridData farmData = farmGrid.data;
#       Vector2 gridPosition = MovementGridController.instance.GetCurrentFarmGridTile();

#       ForageItemData weedOrGrass = farmData.forageItems.list.Find((i) => {
#         return i.position == gridPosition && (
#           i.type == ForageItemData.Type.Weed ||
#           i.type == ForageItemData.Type.TallGrass
#         );
#       });

#       if (weedOrGrass == null) return;

#       new FarmingEvent(new FarmingEventArgs(
#         FarmingEventType.Forage,
#         gridPosition,
#         farmData.userId,
#         farmData.avatarDataName,
#         farmData.collectionName,
#         ((int)weedOrGrass.type).ToString()
#       ));

#       if (
#         SessionManager.match == null &&
#         await farmData.Forage(
#           gridPosition,
#           ((int)weedOrGrass.type).ToString()
#         ) == false
#       )
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }
#   }
# }
