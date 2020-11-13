extends KinematicBody2D

export var user_id: String
export var character_base: String
export var dialogue_file: String
export var dialogue_section: String
export var current_tile: String

const POSITION_COMPARATOR_TIMER_INTERVAL: int = 3000

var username: String  # TODO: Move this to Farmer / Player Controller?
var server_derived_position: String
var movement_target: Vector2
var position_from_server: Vector2
var navigation_points: PoolVector2Array
var current_nav_index: int
var next_movement_point: Vector2
var direction: Vector2
var velocity: Vector2
var position_comparator_timer
var player_position_at_start: Vector2

onready var body_tile_map: TileMap = find_node("Body")
onready var top_tile_map: TileMap = find_node("Top")
onready var bottom_tile_map: TileMap = find_node("Bottom")
onready var hair_tile_map: TileMap = find_node("Hair")
onready var walk_animation: AnimationPlayer = find_node("Walk")
onready var visibility_notifier: VisibilityNotifier2D = find_node("VisibilityNotifier2D")
onready var username_label: Label = $IGN


func is_up() -> bool:
	return direction == Vector2.UP


func is_down() -> bool:
	return direction == Vector2.DOWN


func is_left() -> bool:
	return direction == Vector2.LEFT


func is_right() -> bool:
	return direction == Vector2.RIGHT


func _ready():
	if username != null || username != "":
		set_username(username)

#       positionComparatorTimer = new System.Timers.Timer(positionComparatorTimerInterval);
#       positionComparatorTimer.AutoReset = false;
#       positionComparatorTimer.Enabled = false;
#       positionComparatorTimer.Elapsed += ServerPositionCheck;

#       if (serverDerivedPosition) MoveEventOnLoad();
#       else movementTarget = Position;

#       if (userId != null)
#         MovementEvent.Subscribe(MoveEvent, userId);

#       Material = Material.Duplicate() as Material;

	direction = Vector2.DOWN
	# set_idle()


func set_username(_username: String):
	username_label.text = _username
	username_label.show()


func set_idle():
	walk_animation.Stop()
	current_tile = "1"
	update_current_tile()


func update_current_tile():
	var dir_str: String = "Up"

	if is_down():
		dir_str = "Down"
	elif is_right():
		dir_str = "Right"
	elif is_left():
		dir_str = "Left"

	var base_tile: String = "%s%s %s" % [character_base, dir_str, current_tile]

	var set: TileSet = body_tile_map.tile_set

	if body_tile_map.get_cell(0, -1) != set.find_tile_by_name(base_tile):
		body_tile_map.set_cell(0, -1, set.find_tile_by_name(base_tile), is_left(), false)


func get_direction_relative_to_target(target: Vector2):
	var vector_diff: Vector2 = position - target
	var _direction: Vector2 = Vector2.DOWN

	if vector_diff == Vector2.ZERO:
		_direction = Vector2.DOWN
	elif abs(vector_diff.x) > abs(vector_diff.y):
		_direction = Vector2.RIGHT if vector_diff.x < 0 else Vector2.LEFT
	else:
		_direction = Vector2.DOWN if vector_diff.y < 0 else Vector2.UP

	return direction

#     public override void _ExitTree() {
#       if (userId != null)
#         MovementEvent.Unsubscribe(MoveEvent, userId);
#     }

#     public override void _PhysicsProcess(float delta) {
#       if (navigationPoints == null || navigationPoints.Length == 0) {
#         SetIdle();
#         return;
#       }

#       if (nextMovementPoint.DistanceTo(Position) <= 1) {
#         if (currentNavIndex + 1 < navigationPoints.Length) {
#           currentNavIndex++;
#           nextMovementPoint = navigationPoints[currentNavIndex];
#         } else {
#           nextMovementPoint = Vector2.NegOne;
#           navigationPoints = null;
#           SetIdle();
#           return;
#         }
#       }

#       if (positionComparatorTimer.Enabled == false) {
#         playerPositionAtStart = Position;
#         positionComparatorTimer.Start();
#       }

#       if (walkAnimation.IsPlaying() == false)
#         walkAnimation.Play();

#       PhysicsLoop();
#     }

#     private void PhysicsLoop() {
#       direction = GetDirectionRelativeToTarget(nextMovementPoint);

#       velocity = (nextMovementPoint - Position).Normalized();

#       KinematicCollision2D collision = MoveAndCollide(velocity);

#       if (collision != null)
#         OnCollision(collision);

#       UpdateCurrentTile();
#     }

#     private void ServerPositionCheck(object source, ElapsedEventArgs e) {
#       bool isPlayerStuck = Position.DistanceTo(playerPositionAtStart) < 8;
#       bool playerFarFromServerPosition = Position.DistanceTo(positionFromServer) > 32;

#       if (isPlayerStuck && playerFarFromServerPosition) Position = positionFromServer;
#     }

#     private void MoveEventOnLoad() {
#       MoveEvent(new MovementEventArgs(movementTarget));
#     }

#     public virtual void Interact() {
#       if (!dialogueFile.Empty() && !dialogueSection.Empty()) {
#         DialogueController.Start(dialogueFile, dialogueSection);
#       } else {
#         Logger.Log("Character interaction");
#       }
#     }

#     public virtual void OnCollision(KinematicCollision2D collision) {
#       Logger.Log("Character collision");
#     }

#     public void ColorSwap(
#       string shaderTarget,
#       Vector3 targetColor,
#       Vector3 changeColor
#     ) {
#       ShaderMaterial mat = Material as ShaderMaterial;
#       mat.SetShaderParam($"{shaderTarget}Color", targetColor);
#       mat.SetShaderParam($"{shaderTarget}ChangeColor", changeColor);
#     }

#     private void MoveEvent(MovementEventArgs args) {
#       if (args.ping) {
#         positionFromServer = args.position;
#         return;
#       }

#       movementTarget = args.position;
#       navigationPoints = TPLNavigation2DController.instance.GetSimplePath(Position, movementTarget, true);
#       // NOTE: The below lines draw the dots
#       //TPLNavigation2DController.instance.navigationPoints = navigationPoints;
#       //TPLNavigation2DController.instance.Update();

#       currentNavIndex = 0;

#       if (navigationPoints != null && navigationPoints.Length > 1)
#         nextMovementPoint = navigationPoints[currentNavIndex];
#       else
#         nextMovementPoint = Vector2.NegOne;

#       Update();
#     }
#   }
# }
