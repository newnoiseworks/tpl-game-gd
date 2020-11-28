extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using TPV.Data;
# using TPV.GameEvents;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.MovementGrid;
# using TPV.Utils.Network;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class PailController : ItemController, IEquiptableItem {

#     public static PailController instance;

#     private const int MAX_POURS = 10;
#     private const string FULL_PAIL_TILE_NAME = "Items/Tools/Bucket Full";
#     private const string EMPTY_PAIL_TILE_NAME = "Items/Tools/Bucket Empty";

#     public bool isOverWaterSource;
#     public int poursLeft;

#     private int fullPailIdx;
#     private int emptyPailIdx;

#     public override void _Ready() {
#       base._Ready();

#       instance = this;
#       fullPailIdx = tileMap.TileSet.FindTileByName(FULL_PAIL_TILE_NAME);
#       emptyPailIdx = tileMap.TileSet.FindTileByName(EMPTY_PAIL_TILE_NAME);

#       FillPail();
#     }

#     public async void PrimaryAction() {
#       if (isOverWaterSource && poursLeft < MAX_POURS) {
#         FillPail();
#       } else if (poursLeft > 0 && PlayerController.instance != null && PlayerController.instance.currentFarmGrid != null) {
#         Vector2 tilePos = MovementGridController.instance.GetCurrentFarmGridTile();
#         FarmGridController farmGrid = PlayerController.instance.currentFarmGrid;
#         FarmGridData farmData = farmGrid.data;

#         PlantData plant = farmData.plants.list.Find((p) => p.position == tilePos);

#         if (plant == null) return;

#         PourAndEmptyWhenNeeded();

#         new FarmingEvent(new FarmingEventArgs(
#           FarmingEventType.Water,
#           plant.position,
#           farmData.userId,
#           farmData.avatarDataName,
#           farmData.collectionName,
#           plant.plantType
#         ));

#         if (
#           SessionManager.match == null &&
#           await farmData.Water(
#             plant.position,
#             plant.plantType
#           ) == false
#         )
#           new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#       }
#     }

#     public void FillPail() {
#       tileMap.SetCellv(new Vector2(), fullPailIdx);
#       poursLeft = MAX_POURS;
#     }

#     public void PourAndEmptyWhenNeeded() {
#       poursLeft--;

#       if (poursLeft == 0)
#         tileMap.SetCellv(new Vector2(), emptyPailIdx);
#     }
#   }
# }
