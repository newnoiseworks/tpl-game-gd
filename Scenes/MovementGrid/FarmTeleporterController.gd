extends "res://Scenes/MovementGrid/TeleporterController.gd"

# using Godot;
# using TPV.RootScenes.Farm;

# namespace TPV.Scenes.MovementGrid {

#   public class FarmTeleporterController : TeleporterController {

#     [Export] public bool enabled;

#     public string userIdToJoin;
#     public string userAvatarToJoin;

#     protected override void OnBodyEnter(PhysicsBody2D body) {
#       if (enabled == false || exitEnabled == false) return;

#       sceneToLoad = "RootScenes/Farm/Farm.tscn";
#       exitEnabled = true;

#       FarmController.userIdToJoin = userIdToJoin;
#       FarmController.userAvatarToJoin = userAvatarToJoin;
#       FarmController.joinMatchOnReady = true;

#       base.OnBodyEnter(body);
#     }
#   }
# }
