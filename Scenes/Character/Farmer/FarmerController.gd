extends "res://Scenes/Character/CharacterController.gd"

export var is_animation_playing: bool
export var current_tool_tile: String

var avatar_data
var hearts = []

onready var till_animation: AnimationPlayer = $Till
onready var strike_animation: AnimationPlayer = $Strike
onready var scythe_animation: AnimationPlayer = $Scythe
onready var axe_animation: AnimationPlayer = $Axe
onready var pickup_animation: AnimationPlayer = $Pickup
onready var tool_tile_map: TileMap = find_node("ToolTile")
onready var back_tool_tile_map: TileMap = find_node("BackToolTile")
onready var hair_tile_map: TileMap = find_node("Hair")
onready var top_tile_map: TileMap = find_node("Top")
onready var bottom_tile_map: TileMap = find_node("Bottom")
onready var heart_sprite: Sprite = find_node("Heart")
onready var heart_tweener: Tween = find_node("HeartTweener")


func _enter_tree():
	character_base = "Avatars/base/#"

	is_animation_playing = false
	current_tool_tile = ""

	if user_id != "":
		MatchEvent.connect("farming", self, "handle_farming_event")
		MatchEvent.connect("avatar_update", self, "handle_avatar_update_event")
		MatchEvent.connect("heart", self, "handle_heart")

	if hearts.size() > 0:
		clear_hearts()


func _ready():
	stop_all_animations()
	tool_tile_map.clear()
	back_tool_tile_map.clear()
	current_tool_tile = ""
	heart_tweener.connect("tween_all_completed", self, "clear_hearts")


func _exit_tree():
	if user_id != "":
		MatchEvent.disconnect("farming", self, "handle_farming_event")
		MatchEvent.disconnect("avatar_update", self, "handle_avatar_update_event")
		MatchEvent.disconnect("heart", self, "handle_heart")


func _physics_process(_delta: float):
	if is_animation_playing:
		pause_physics_process = true
		update_current_tile()
	else:
		pause_physics_process = false


func handle_heart(_msg, presence):
	if presence.user_id != user_id:
		return

	var heart = heart_sprite.duplicate()
	heart.show()
	hearts.append(heart)
	call_deferred("add_child", heart)
	heart_tweener.interpolate_property(
		heart, "position", Vector2(0, 0), Vector2(0, -24), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	heart_tweener.interpolate_property(
		heart,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		3,
		Tween.TRANS_BOUNCE,
		Tween.EASE_IN
	)
	heart_tweener.call_deferred("start")


func clear_hearts():
	for heart in hearts:
		if heart != null:
			heart.queue_free()


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


func on_collision(collision: KinematicCollision2D):
	movement_target = position

	if collision.collider.user_id != null:
		return

	set_idle()


func handle_avatar_update_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != user_id:
		return

	# var args = JSON.parse(msg).result

	var profile = yield(SaveData.load("profile", SaveData.all_avatars_key, user_id), "completed")

	for i in range(profile.avatars.size()):
		var avatar = profile.avatars[i]

		if avatar.key == avatar_data.key:
			avatar_data = avatar

			if user_id == SessionManager.session.user_id:
				SessionManager.current_avatar = avatar
				SessionManager.profile_data = profile

			update_current_tile()

			break


func handle_farming_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != user_id:
		return

	var args = JSON.parse(msg).result
	var farm_grid

	for fg in TPLG.current_farm_grids:
		if (
			fg.collection_name == args.farm_collection
			&& fg.owner_id == args.farm_owner_id
			&& fg.owner_avatar_name == args.farm_owner_avatar
		):
			farm_grid = fg

	direction = get_direction_relative_to_target(movement_target)

	match int(args.type):
		FarmEvent.PLANT:
			stop_all_animations()
			pickup_animation.play("Main")
		FarmEvent.TILL:
			stop_all_animations()
			till_animation.play("Main")
		FarmEvent.HARVEST:
			stop_all_animations()
			pickup_animation.play("Main")
		FarmEvent.FORAGE:
			stop_all_animations()

			match int(args.metadata):
				ForageItems.TREE:
					axe_animation.play("Main")
				ForageItems.STONE:
					strike_animation.play("Main")
				ForageItems.WEED:
					scythe_animation.play("Main")
				ForageItems.TALL_GRASS:
					scythe_animation.play("Main")
		FarmEvent.DETILL:
			stop_all_animations()
			strike_animation.play("Main")
		FarmEvent.WATER:
			pass

	if farm_grid == null:
		print_debug(
			(
				"Couldn't find a farm grid to match FarmingEvent request from %s, seeking grid owned by %s at avatar %s at farm collection %s"
				% [name, args.farm_owner_id, args.farm_owner_avatar, args.farm_collection]
			)
		)
	else:
		farm_grid.on_farming_event(args)
