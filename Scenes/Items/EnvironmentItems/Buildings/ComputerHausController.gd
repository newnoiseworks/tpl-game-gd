extends "res://Scenes/Items/ItemController.gd"

#     public override void _Ready() {
#       base._Ready();
#       DialogueController.dialogueScripts.Add("computerHausStore", StartStore);

#     }

#     public override void _ExitTree() {
#       base._ExitTree();
#       DialogueController.dialogueScripts.Remove("computerHausStore");
#     }

#     public override void Interact() {
#       DialogueController.Start("ComputerHaus", "hello");
#     }

#     public void StartStore() {
#       StoreController.instance.PopulateStore(new List<InventoryItemType>() {
#         InventoryItemType.CabbageSeeds,
#         InventoryItemType.BeetSeeds,
#         InventoryItemType.DragonFruitSeeds,
#         InventoryItemType.EggplantSeeds,
#         InventoryItemType.TomatoSeeds,
#         InventoryItemType.TurnipSeeds,
#         InventoryItemType.PotatoSeeds,
#         InventoryItemType.TurnipSeeds,
#       }, new List<InventoryItemType>() {
#         InventoryItemType.Cabbage,
#         InventoryItemType.Beet,
#         InventoryItemType.DragonFruit,
#         InventoryItemType.Eggplant,
#         InventoryItemType.Tomato,
#         InventoryItemType.Turnip,
#         InventoryItemType.Potato,
#         InventoryItemType.Turnip,
#       });
#     }
#   }
# }
