extends Node2D

# using Godot;
# using TPV.Utils;
# using System.Timers;

# namespace TPV.Scenes.Items.EnvironmentItems.Lights {

#   public class SunController : Node2D {

#     private PathFollow2D pathFollow;
#     private System.Timers.Timer timer;
#     private Light2D sun;
#     private CanvasModulate nightSky;

#     public override void _Ready() {
#       Show();
#       sun = FindNode("Sun") as Light2D;
#       nightSky = FindNode("NightSky") as CanvasModulate;
#       pathFollow = FindNode("SunPathFollow2D") as PathFollow2D;
#       timer = new System.Timers.Timer(1000);
#       timer.Elapsed += ProcessAtmosphere;
#       timer.AutoReset = true;
#       timer.Start();

#       ProcessAtmosphere();
#     }

#     public override void _ExitTree() {
#       timer.Stop();
#       timer.Dispose();
#       timer = null;

#       base._ExitTree();
#     }

#     private void ProcessAtmosphere(object source = null, ElapsedEventArgs e = null) {
#       if (timer == null) {
#         Logger.Log("Timer still elapsing on Sun Controller for some reason...");
#         return;
#       }

#       if (GameTime.IsDay())
#         CallDeferred("PositionSun");
#       else
#         CallDeferred("SetupNightSky");
#     }

#     private void SetupNightSky() {
#       if (sun.Enabled) sun.Enabled = false;
#       if (nightSky.Visible == false) nightSky.Show();

#       float hoursOfNightfallPassed;

#       // TODO: Maybe move the below into a generic GameTime.GetPercentageOfNightComplete
#       if (GameTime.inGameHour > 12)
#         hoursOfNightfallPassed = GameTime.inGameHour - GameTime.NIGHTFALL;
#       else
#         hoursOfNightfallPassed = GameTime.inGameHour + (24 - GameTime.NIGHTFALL);

#       float percentageOfNightComplete = hoursOfNightfallPassed / ((24 - GameTime.NIGHTFALL) + GameTime.DAYBREAK);

#       float currentNightIntensityPercentage;

#       if (percentageOfNightComplete > 0.5f)
#         currentNightIntensityPercentage = 1f - Mathf.Abs(percentageOfNightComplete - 0.5f) / 0.5f;
#       else
#         currentNightIntensityPercentage = percentageOfNightComplete * 2;

#       Color color = nightSky.Color;

#       color.r = 1 - ((1 - 0.17f) * currentNightIntensityPercentage);
#       color.g = 1 - ((1 - 0.03f) * currentNightIntensityPercentage);
#       color.b = 1 - ((1 - 0.38f) * currentNightIntensityPercentage);

#       nightSky.Color = color;
#     }

#     private void PositionSun() {
#       if (sun.Enabled == false) sun.Enabled = true;

#       Color color = nightSky.Color;
#       color.r = 1;
#       color.g = 1;
#       color.b = 1;
#       nightSky.Color = color;

#       float percentageOfDayComplete = GameTime.GetPercentageOfDayComplete();
#       float percentageOfSunPathComplete = Mathf.Clamp((percentageOfDayComplete - 0.25f) / (0.83f - 0.25f), 0, 0.99f);

#       float energyOfSun = Mathf.Abs(percentageOfSunPathComplete - 0.5f) + .75f;

#       sun.Energy = energyOfSun;
#       pathFollow.UnitOffset = percentageOfSunPathComplete;
#     }
#   }
# }
