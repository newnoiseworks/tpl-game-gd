extends Area2D

# using Godot;
# using TPV.Scenes.Character;
# using TPV.Utils.Network;

# namespace TPV.Scenes.MovementGrid {

#   public class TemporarilyCollidableToggleController : Area2D {

#     [Export] public bool restrictToStart;

#     public string restrictToNodeName;

#     private int collisionLayer = 3;
#     private Node2D cones;
#     private Vector2 originalConePos;

#     public override void _Ready() {
#       cones = FindNode("Cones") as Node2D;
#       originalConePos = cones.Position;

#       if (restrictToStart || restrictToNodeName != null)
#         GateOn();
#       else
#         GateOff();
#     }

#     public void GateOn() {
#       cones.Show();
#       cones.Position = originalConePos;
#     }

#     public void GateOff() {
#       cones.Hide();
#       cones.Position = new Vector2(-99999999, -99999999);
#     }

#     private void BodyEntered(object body) {
#       CharacterController character = body as CharacterController;

#       if (character == null) return;

#       if ((restrictToNodeName != null || restrictToStart) && restrictToNodeName != character.Name) return;

#       if (character.Name != SessionManager.GetUserId())
#         GateOff();

#       character.SetCollisionLayerBit(collisionLayer, false);
#     }

#     private void BodyExit(object body) {
#       CharacterController character = body as CharacterController;

#       if (character == null) return;

#       if ((restrictToNodeName != null || restrictToStart) && restrictToNodeName != character.Name) return;

#       if (character.Name != SessionManager.GetUserId())
#         GateOn();

#       character.SetCollisionLayerBit(collisionLayer, true);
#     }
#   }
# }
