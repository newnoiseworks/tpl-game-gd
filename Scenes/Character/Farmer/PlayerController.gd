# using Godot;
# using TPV.Utils;
# using TPV.Scenes.FarmGrid;
# using TPV.Scenes.MovementGrid;
# using TPV.Scenes.UI.Inventory;
# using TPV.Scenes.Items;
# using TPV.GameEvents;
# using System.Collections.Generic;
# using TPV.Scenes.Items.EquiptableItems;
# using System.Timers;
# using TPV.Autoload;

# namespace TPV.Scenes.Character.Farmer {

#   public class PlayerController : FarmerController {

#     public static PlayerController instance;

#     public FarmGridController currentFarmGrid;
#     public ItemController itemUnderTarget;
#     public Vector2 areaToUseEquippedItem;
#     public bool lockMovement;
#     public Camera2D camera;

#     private const int MOVE_POSITION_FROM_BUTTON = 32;
#     private const float MOVE_DELAY_MINIMUM = .25f;
#     private const int movementPingTimerInterval = 150;

#     private Dictionary<string, float> mapConstraints = new Dictionary<string, float>();
#     private float lastMoveCounter;
#     private System.Timers.Timer movementPingTimer;

#     public static void LockMovement() {
#       instance.lockMovement = true;
#     }

#     public static void UnlockMovement() {
#       instance.lockMovement = false;
#     }

#     public override void _Ready() {
#       base._Ready();
#       instance = this;
#       NodeManager.ScheduleFree(FindNode("CharacterInteractItem"));
#       MoveTargetAsNeeded(Position);

#       movementPingTimer = new System.Timers.Timer(movementPingTimerInterval);
#       movementPingTimer.Elapsed += OnMovementPingTimerEvent;
#       movementPingTimer.AutoReset = true;
#       movementPingTimer.Enabled = false;
#       camera = FindNode("Camera2D") as Camera2D;
#     }

#     public override void _ExitTree() {
#       base._ExitTree();
#       instance = null;
#     }

#     public override void _PhysicsProcess(float delta) {
#       if (navigationPoints == null || navigationPoints.Length == 0) {
#         if (movementPingTimer.Enabled) {
#           movementPingTimer.Stop();
#           SendMovementPingUpdate();
#         }
#       } else {
#         movementPingTimer.Start();
#       }

#       base._PhysicsProcess(delta);

#       if (lockMovement) return;

#       lastMoveCounter += delta;

#       if (InputController.Moving(null, true, true) && !InputController.Moving(null))
#         OrientTargetToPositionOnButtonUp(Position);
#       else if (lastMoveCounter >= MOVE_DELAY_MINIMUM && InputController.Moving())
#         UpdateTargetIfNeeded();

#       if (
#         instance != null
#         && areaToUseEquippedItem != Vector2.Inf
#         && areaToUseEquippedItem.DistanceTo(instance.Position) < 3
#       ) {
#         UseEquippedItem();
#         areaToUseEquippedItem = Vector2.Inf;
#       }
#     }

#     public override void _UnhandledInput(InputEvent @event) {
#       if (lockMovement) return;

#       if (@event is InputEventMouseButton mouseEvent) {

#         if (mouseEvent.IsActionReleased("action_one")) {
#           if (UpdateTargetIfNeeded(true) == false && itemUnderTarget?.currentInteractingPlayer == this)
#             itemUnderTarget.Interact();
#         }

#         if (mouseEvent.IsActionReleased("action_two")) {
#           UpdateTargetIfNeeded(true);
#           areaToUseEquippedItem = movementTarget;
#         }

#         if (mouseEvent.IsActionReleased("action_three")) {
#           SecondaryActionOnCursorItem();
#         }

#         return;
#       }

#       if (@event.IsActionReleased("action_one")) {
#         if (itemUnderTarget != null) {
#           itemUnderTarget.Interact();
#         }
#       }

#       if (@event.IsActionReleased("action_two")) {
#         UseEquippedItem();
#       }

#       if (@event.IsActionReleased("action_three")) {
#         SecondaryActionOnCursorItem();
#       }

#       if (@event.IsActionReleased("action_four")) {
#         InventoryController.instance.ShiftEquiptItem(false);
#       }

#       if (@event.IsActionReleased("action_five")) {
#         InventoryController.instance.ShiftEquiptItem();
#       }
#     }

#     public void RestrictCameraToTileMap(TileMap map) {
#       Rect2 limits = map.GetUsedRect();
#       Vector2 cellSize = map.CellSize;

#       camera.LimitLeft = (int)Mathf.Round(limits.Position.x * cellSize.x);
#       camera.LimitRight = (int)Mathf.Round(limits.End.x * cellSize.x);
#       camera.LimitTop = (int)Mathf.Round(limits.Position.y * cellSize.y);
#       camera.LimitBottom = (int)Mathf.Round(limits.End.y * cellSize.y);

#       mapConstraints.Add("left", camera.LimitLeft);
#       mapConstraints.Add("right", camera.LimitRight);
#       mapConstraints.Add("top", camera.LimitTop);
#       mapConstraints.Add("bottom", camera.LimitBottom);
#     }

#     private void OnMovementPingTimerEvent(object source, ElapsedEventArgs e) {
#       SendMovementPingUpdate();
#     }

#     private void SendMovementPingUpdate() {
#       new MovementEvent(
#         new MovementEventArgs(Position, true),
#         userId
#       );
#     }

#     private void UseEquippedItem() {
#       if (InventoryController.instance.equippedItem != null)
#         InventoryController.instance.equippedItem.PrimaryAction();
#     }

#     private void SecondaryActionOnCursorItem() {
#       IEquiptableDualActionItem item = itemUnderTarget as IEquiptableDualActionItem;

#       if (item != null) {
#         item.SecondaryAction();
#       }
#     }

#     private bool UpdateTargetIfNeeded(bool mouseMovement = false) {
#       Vector2 target;

#       if (mouseMovement) {
#         target = GetGlobalMousePosition();
#       } else {
#         target = Position;

#         if (InputController.Moving("up"))
#           target.y -= MOVE_POSITION_FROM_BUTTON;

#         if (InputController.Moving("down"))
#           target.y += MOVE_POSITION_FROM_BUTTON + 16;

#         if (InputController.Moving("left"))
#           target.x -= MOVE_POSITION_FROM_BUTTON + 16;

#         if (InputController.Moving("right"))
#           target.x += MOVE_POSITION_FROM_BUTTON + 16;
#       }

#       if (target.x < mapConstraints["left"] || target.x > mapConstraints["right"] || target.y < mapConstraints["top"] || target.y > mapConstraints["bottom"]) return false;

#       return MoveTargetAsNeeded(target, mouseMovement);
#     }

#     private void OrientTargetToPositionOnButtonUp(Vector2 position) {
#       Vector2 offset;

#       if (isRight) offset = new Vector2(1, 0);
#       else if (isLeft) offset = new Vector2(-1, 0);
#       else if (isUp) offset = new Vector2(0, -1);
#       else offset = new Vector2(0, 1);

#       new MovementEvent(new MovementEventArgs(position + offset), userId);

#       Vector2 target = MovementGridController.instance.WorldToMap(position);

#       if (isRight) target.x++;
#       else if (isLeft) target.x--;

#       if (isDown) target.y = target.y + 2;
#       else if (isUp) target.y--;

#       MovementGridController.instance.SetTargetTileFrom(target * 16);
#     }

#     private bool MoveTargetAsNeeded(Vector2 target, bool mouseMovement = false) {
#       if (mouseMovement) {
#         MovementGridController.instance.SetTargetTileFrom(target);
#         target = MovementGridController.instance.GetTilePosition();

#         direction = GetDirectionRelativeToTarget(target * 16);

#         if (isRight) target.x -= 1;
#         if (isLeft) target.x += 1;
#         if (isDown) target.y -= 1;
#         if (isUp) target.y += 1;

#         target *= 16;

#         target.x += 8; // compensating as farmers are "centered"

#         if (target != this.movementTarget) {
#           lastMoveCounter = 0;

#           new MovementEvent(
#             new MovementEventArgs(target),
#             userId
#           );

#           return true;
#         }
#       } else {
#         if (isLeft || isRight) {
#           target.y++;
#         }

#         MovementGridController.instance.SetTargetTileFrom(target);

#         if (target != this.movementTarget) {
#           lastMoveCounter = 0;

#           new MovementEvent(
#             new MovementEventArgs(target),
#             userId
#           );

#           return true;
#         }
#       }

#       return false;
#     }
#   }
# }
