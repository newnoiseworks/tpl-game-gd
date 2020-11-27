extends Label

# using Godot;
# using System;
# using TPV.Utils;

# namespace TPV.Scenes.UI {

#   public class GameTimeLabelController : Label {

#     private int inGameHour;
#     private int inGameMinute;
#     public override void _PhysicsProcess(float delta) {
#       if (inGameHour != GameTime.inGameHour && inGameMinute != GameTime.inGameMinute) {
#         inGameHour = GameTime.inGameHour;
#         inGameMinute = GameTime.inGameMinute;
#         Text = GameTime.GetRoundedTime();
#       }
#     }
#   }
# }
