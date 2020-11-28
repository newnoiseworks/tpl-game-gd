extends "res://Scenes/Items/CraftedItemController.gd"

# using Godot;
# using TPV.Utils;
# using TPV.Scenes.Items.EquiptableItems;

# namespace TPV.Scenes.Items.EnvironmentItems.Lights {

#   public class LampController : CraftedItemController, IEquiptableInventoryReadiedItem {

#     private Light2D light;

#     public override void _Ready() {
#       base._Ready();

#       light = (Light2D)FindNode("Light2D");

#       if (GameTime.IsDay())
#         TurnLampOff();
#       else
#         TurnLampOn();

#       GameTime.TriggerDaybreakEvent += TurnLampOff;
#       GameTime.TriggerNightfallEvent += TurnLampOn;
#     }

#     public override void _ExitTree() {
#       base._ExitTree();

#       GameTime.TriggerDaybreakEvent -= TurnLampOff;
#       GameTime.TriggerNightfallEvent -= TurnLampOn;
#     }

#     public void TurnLampOff() {
#       // light.Visible = false;
#       light.Enabled = false;
#     }

#     public void TurnLampOn() {
#       // light.Visible = true;
#       light.Enabled = true;
#     }


func ready_for_inventory():
	find_node("TileMap").hide()
	find_node("Inventory").show()

# GameTime.TriggerDaybreakEvent -= TurnLampOff;
# GameTime.TriggerNightfallEvent -= TurnLampOn;

# TurnLampOff();
