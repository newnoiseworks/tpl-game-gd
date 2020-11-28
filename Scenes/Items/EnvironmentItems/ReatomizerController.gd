extends "res://Scenes/Items/ItemController.gd"

# using System.Collections.Generic;
# using TPV.Data;
# using TPV.Scenes.UI.Store;

# namespace TPV.Scenes.Items.EnvironmentItems {

#   public class ReatomizerController : ItemController {

#     public static ReatomizerController instance;
#     public ReatomizerData data;

#     public override void _Ready() {
#       instance = this;
#       base._Ready();

#       data = new ReatomizerData();
#     }

#     public async override void Interact() {
#       await data.Load();
#       SetupStore();
#     }

#     private void SetupStore() {
#       if (data.blueprints.Count == 0) {
#         TPV.Scenes.UI.UIController.ShowToast("Get some blueprints from Violine in town!");
#         return;
#       }

#       List<InventoryItemType> craftableItems = new List<InventoryItemType>();

#       foreach (InventoryItemType blueprint in data.blueprints)
#         craftableItems.Add(ReatomizerData.blueprintToItems[blueprint]);

#       StoreController.instance.PopulateStore(craftableItems);
#     }
#   }
# }
