extends "res://Scenes/Character/CharacterController.gd"

#     public static List<FarmGridController> currentFarmGrids = new List<FarmGridController>();

export var is_animation_playing: bool
export var current_tool_tile: String

var avatar_data

onready var till_animation: AnimationPlayer = $Till
onready var strike_animation: AnimationPlayer = $Strike
onready var scythe_animation: AnimationPlayer = $Scythe
onready var axe_animation: AnimationPlayer = $Axe
onready var pickup_animation: AnimationPlayer = $Pickup
onready var tool_tile_map: TileMap = find_node("ToolTile")
onready var back_tool_tile_map: TileMap = find_node("BackToolTile")


func _ready():
	character_base = "Avatars/base/#"

	stop_all_animations()
	is_animation_playing = false
	current_tool_tile = ""
	tool_tile_map.clear()
	back_tool_tile_map.clear()

	set_idle()


#       if (userId != null) {
#         FarmingEvent.Subscribe(HandleFarmingEvent, userId);
#         AvatarUpdateEvent.Subscribe(HandleAvatarUpdateEvent, userId);
#       }
#     }


func _physics_process(_delta: float):
	if is_animation_playing:
		update_current_tile()
	else:
		update_current_tile()
	# else:
	# 	._physics_process(delta)


func stop_all_animations():
	walk_animation.stop()
	till_animation.stop()
	strike_animation.stop()
	scythe_animation.stop()
	axe_animation.stop()
	pickup_animation.stop()


func set_idle():
	current_tile = "idle 0"
	direction = get_direction_relative_to_target(movement_target)
	update_current_tile()


func update_current_tile():
	if avatar_data == null:
		tool_tile_map.clear()
		back_tool_tile_map.clear()
		return

	set_tile_part(top_tile_map, "bodies", String(avatar_data.topType))
	set_tile_part(bottom_tile_map, "legs", String(avatar_data.bottomType))
	set_tile_part(hair_tile_map, "heads", String(avatar_data.hairType))
	set_tile_part(body_tile_map, "base", String(avatar_data.baseType))

	if current_tool_tile != "" && current_tool_tile != null:
		set_tile_part(tool_tile_map, "tools")
	else:
		tool_tile_map.clear()
		back_tool_tile_map.clear()


func set_tile_part(map: TileMap, part_folder: String, outfit: String = "", dir_str: String = ""):
	var is_left: bool = false

	if dir_str == "":
		dir_str = "back"

		if direction == Vector2.DOWN:
			dir_str = "front"
		elif direction == Vector2.RIGHT:
			dir_str = "sideR"
		elif direction == Vector2.LEFT:
			dir_str = "sideL"

	var tile: int = assemble_and_return_tilename(map, part_folder, dir_str, outfit)

	if dir_str == "sideL" && tile == -1:
		is_left = true
		tile = assemble_and_return_tilename(map, part_folder, "sideR", outfit)
		if tile == -1:
			tile = assemble_and_return_tilename(map, part_folder, "side", outfit)
	elif dir_str == "sideR" && tile == -1:
		tile = assemble_and_return_tilename(map, part_folder, "side", outfit)

	if tile == -1 && ! ("B" in dir_str):
		set_tile_part(map, part_folder, outfit, dir_str + "B")
	elif tile > -1:
		reposition_and_set_tile(tile, map, dir_str, part_folder, is_left)


func reposition_and_set_tile(
	tile: int, map: TileMap, dir_str: String, part_folder: String, is_left: bool
):
	if part_folder == "tools":
		if "B" in dir_str:
			map.clear()
			map = back_tool_tile_map
		else:
			back_tool_tile_map.clear()

		if is_left:
			map.position = Vector2(-8, 20)
		else:
			map.position = Vector2(-24, 20)

	if map.get_cell(0, -1) != tile:
		map.set_cell(0, -1, tile, is_left, false)


func assemble_and_return_tilename(map: TileMap, part: String, dir_str: String, outfit: String = ""):
	var tile_end: String = current_tile

	if part == "tools":
		tile_end = current_tool_tile

	var outfit_part: String = ""
	if outfit != "":
		outfit_part = "%s/" % outfit

	var tilename: String = "Avatars/%s/%s#%s_%s" % [part, outfit_part, dir_str, tile_end]

	return map.tile_set.find_tile_by_name(tilename)

#     public override void _ExitTree() {
#       base._ExitTree();

#       if (userId != null) {
#         FarmingEvent.Unsubscribe(HandleFarmingEvent, userId);
#         AvatarUpdateEvent.Unsubscribe(HandleAvatarUpdateEvent, userId);
#       }
#     }

#     public override void _PhysicsProcess(float delta) {
#       if (is_animation_playing) {
#         UpdateCurrentTile();
#       } else {
#         base._PhysicsProcess(delta);
#       }
#     }

#     public override void OnCollision(KinematicCollision2D collision) {
#       movementTarget = Position;

#       if (collision.Collider is CharacterController) return;

#       SetIdle();
#     }

#     private async void HandleAvatarUpdateEvent(AvatarUpdateEventArgs args) {
#       ProfileData profile = new ProfileData(userId);

#       await profile.Load();

#       for (int i = 0; i < profile.avatars.Count; i++) {
#         AvatarData avatar = profile.avatars.list[i];

#         if (avatar.key == avatarData.key) {
#           avatarData = avatar;

#           if (userId == SessionManager.GetUserId())
#             SessionManager.currentCharacter = avatar;

#           // Decorate();
#           break;
#         }
#       }
#     }

#     private void HandleFarmingEvent(FarmingEventArgs args) {
#       FarmGridController farmGrid = currentFarmGrids.Find((fg) =>
#         fg.collectionName == args.farmCollection &&
#         fg.ownerId == args.farmOwnerId &&
#         fg.ownerAvatarName == args.farmOwnerAvatar
#       );

#       direction = GetDirectionRelativeToTarget(MovementGrid.MovementGridController.instance.Position);

#       switch (args.type) {
#         case FarmingEventType.Plant:
#           StopAllAnimations();
#           pickupAnimation.Play();
#           break;
#         case FarmingEventType.Till:
#           StopAllAnimations();
#           tillAnimation.Play();
#           break;
#         case FarmingEventType.Harvest:
#           StopAllAnimations();
#           pickupAnimation.Play();
#           break;
#         case FarmingEventType.Forage:
#           StopAllAnimations();

#           switch ((ForageItemData.Type)(Int32.Parse(args.metadata))) {
#             case (ForageItemData.Type.Tree):
#               axeAnimation.Play();
#               break;
#             case (ForageItemData.Type.Stone):
#               strikeAnimation.Play();
#               break;
#             case (ForageItemData.Type.Weed):
#             case (ForageItemData.Type.TallGrass):
#               scytheAnimation.Play();
#               break;
#           }
#           break;
#         case FarmingEventType.Detill:
#           StopAllAnimations();
#           strikeAnimation.Play();
#           break;
#         case FarmingEventType.Water:
#           break;
#       }

#       if (farmGrid == null) {
#         Logger.Log($"Couldn't find a farm grid to match FarmingEvent request from {Name}, seeking grid owned by {args.farmOwnerId} at avatar {args.farmOwnerAvatar} at farm collection {args.farmCollection}");
#       } else {
#         farmGrid.OnFarmingEvent(args);
#       }
#     }
#   }
# }
