extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.MovementGrid;
# using TPV.Utils;
# using TPV.Utils.Network;
# using TPV.Scenes.UI.Inventory;
# using TPV.GameEvents;
# using TPV.Data;

# namespace TPV.Scenes.Items.EquiptableItems.Seeds {

#   public class SeedPackController : ItemController, IEquiptableItem {

#     [Export] public string type;

#     private InventoryItemType inventoryType;

#     public override void _Ready() {
#       base._Ready();
#       inventoryType = PlantData.seedItemTypeMap[type];
#     }

#     public void PrimaryAction() {
#       PlayerController player = PlayerController.instance;

#       if (PlayerController.instance.currentFarmGrid == null) return;
#       if (CanAddPlantTo(player, PlayerController.instance.currentFarmGrid) == false) return;

#       FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;

#       if (farmGrid.IsUserOwner() == false && farmGrid.GetPermissions().till != FarmPermission.Can) {
#         TPV.Scenes.UI.UIController.ShowToast("You don't have permission to plant seeds on this farm!");
#         return;
#       }

#       InventoryController.instance.bag.RemoveItemLocally(inventoryType);

#       FarmGridData farmData = farmGrid.data;

#       new FarmingEvent(
#         new FarmingEventArgs(
#           FarmingEventType.Plant,
#           MovementGridController.instance.GetCurrentFarmGridTile(),
#           farmData.userId,
#           farmData.avatarDataName,
#           farmData.collectionName,
#           InventoryItemIDHelper.GetHash(inventoryType)
#         ),
#         player.userId
#       );

#       if (SessionManager.match == null) PlantRPCMethod(farmData);
#     }

#     private async void PlantRPCMethod(FarmGridData farmData) {
#       bool plantOk = await farmData.Plant(
#         MovementGridController.instance.GetCurrentFarmGridTile(),
#         InventoryItemIDHelper.GetHash(inventoryType)
#       );

#       // if (plantOk)
#       // await InventoryController.instance.bag.ReloadBag();
#       // else
#       // new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));

#       if (!plantOk)
#         new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#     }

#     private bool CanAddPlantTo(
#       PlayerController player,
#       FarmGridController farmGrid
#     ) {
#       Vector2 gridPosition = MovementGridController.instance.GetCurrentFarmGridTile();

#       if (farmGrid.data.plants.list.Exists((p) => p.position == gridPosition)) return false;

#       string tilename = farmGrid.GetGroundMapTilenameFromPosition(gridPosition);

#       if (tilename == null) return false;

#       return tilename.Contains(TileAdjuster.searchString);
#     }
#   }
# }
