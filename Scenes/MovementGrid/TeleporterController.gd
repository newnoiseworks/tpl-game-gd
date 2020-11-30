extends Area2D

export var scene_to_load: String
export var exit_enabled: bool

# using Godot;
# using TPV.RootScenes;
# using TPV.Scenes.Character.Farmer;
# using TPV.Utils.Network;
# using TPV.Scenes.UI;

# namespace TPV.Scenes.MovementGrid {
#   public class TeleporterController : Area2D {

#     public static string lastScene;

#     protected virtual async void OnBodyEnter(PhysicsBody2D body) {
#       PlayerController player = body as PlayerController;

#       if (player != null && exitEnabled && player == PlayerController.instance) {
#         UIController.ShowLoadingDialog();
#         await MatchManager.LeaveMatch();

#         lastScene = RootController.rootInstance.sceneName;
#         BaseViewportsController.instance.ChangeScene($"res://{sceneToLoad}");

#         if (SessionManager.match != null)
#           await MatchManager.LeaveMatch();
#       }
#     }

#     private void OnBodyExit(PhysicsBody2D body) {
#       PlayerController player = body as PlayerController;

#       if (player != null && player == PlayerController.instance)
#         exitEnabled = true;
#     }
#   }
# }
