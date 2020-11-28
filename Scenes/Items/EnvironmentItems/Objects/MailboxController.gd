extends "res://Scenes/Items/ItemController.gd"

# using Godot;
# using System.Collections.Generic;
# using TPV.Data;

# namespace TPV.Scenes.Items.EnvironmentItems.Objects {

#   public class MailboxController : ItemController {

#     public string userId;
#     public string userAvatarKey;

#     private StaticBody2D staticBody;
#     private AvatarData data;
#     private uint mask;
#     private uint layer;

#     public override void _Ready() {
#       staticBody = (StaticBody2D)FindNode("StaticBody2D");
#       mask = staticBody.CollisionMask;
#       layer = staticBody.CollisionLayer;
#     }

#     public async void SetUserAndShow(string userId, string userAvatarKey) {
#       if (this.userId != userId || this.userAvatarKey != userAvatarKey) {
#         this.userAvatarKey = userAvatarKey;
#         this.userId = userId;

#         ProfileData data = new ProfileData(userId);
#         await data.Load();
#         this.data = data.avatars.list.Find(a => a.key == userAvatarKey);
#       }

#       staticBody.CollisionMask = mask;
#       staticBody.CollisionLayer = layer;
#       Show();
#     }

#     public void HideAndDisable() {
#       staticBody.CollisionMask = 0;
#       staticBody.CollisionLayer = 0;
#       Hide();
#     }

#     public override void Interact() {
#       if (data == null) return;

#       TPV.Scenes.UI.DialogueController.Start(new Dictionary<string, string>() {
#         { "whom", "mailbox" },
#         { "text", $"{data.name}'s Farm" },
#         { "options", null },
#         { "next", null },
#         { "script", null },
#       });
#     }
#   }
# }
