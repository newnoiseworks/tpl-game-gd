extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using TPV.Scenes.Character.Farmer;
# using TPV.Scenes.Items.EnvironmentItems;
# using TPV.Utils;
# using TPV.Data;

# namespace TPV.Scenes.Items.EquiptableItems {

#   public class BlueprintController : ItemController, IEquiptableItem {

#     [Export] public string blueprintType;

#     public async void PrimaryAction() {
#       InventoryItemType type = InventoryItemIDHelper.GetEnumFromName($"Blueprint_{blueprintType}");
#       await ReatomizerController.instance.data.AddBlueprint(type);
#     }
#   }
# }
