extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using System;
# using TPV.Scenes.Character.Farmer;
# using Nakama.TinyJson;
# using TPV.Data;
# using TPV.Scenes.UI.Inventory;
# using System.Collections.Generic;
# using static Godot.Tween;
# using TPV.Utils;
# using TPV.Scenes.UI;
# using TPV.Autoload;

# namespace TPV.Scenes.Items {
#   public class DropItemController : ItemController {

#     [Export] public string inventoryItemType;
#     public ForageItemData forageItemData;
#     public string farmOwnerId;
#     public string farmOwnerAvatar;
#     public string farmOwnerCollection;

#     private InventoryItemType type;
#     private Tween tween;

#     public override void _Ready() {
#       base._Ready();

#       tween = (Tween)FindNode("Tween");
#       type = (InventoryItemType)Enum.Parse(typeof(InventoryItemType), inventoryItemType);
#     }

#     public async override void OnBodyEnter(PhysicsBody2D body) {
#       if (body as PlayerController == null) return;

#       if (
#         InventoryController.instance.bag.HasEmptySlot() == -1 &&
#         InventoryController.instance.bag.HasItem(type) == false
#       ) {
#         UIController.ShowToast("Inventory Full!");
#         Logger.Log("TODO: Need to implement multi row inventory");
#         return;
#       }

#       Vector2 destination = PlayerController.instance.Position - ((Node2D)GetParent()).Position;

#       tween.InterpolateProperty(
#         this,
#         "position",
#         Position,
#         destination,
#         0.35f,
#         TransitionType.Quint,
#         EaseType.In
#       );

#       tween.Start();

#       await InventoryController.instance.bag.AddItemToBag(
#         type,
#         new Dictionary<string, object>() {
#           { "farm_owner_id", farmOwnerId },
#           { "farm_owner_avatar", farmOwnerAvatar },
#           { "farm_owner_collection", farmOwnerCollection },
#           { "x", forageItemData.position.x },
#           { "y", forageItemData.position.y },
#           { "forage_item_type", (int)forageItemData.type },
#         }.ToJson()
#       );
#     }

#     private void OnTweenComplete(Godot.Object @object, NodePath key) {
#       NodeManager.ScheduleFree(this);
#     }
#   }
# }
