extends Node2D

export var on_ground: bool
export var is_crafted: bool
export var crafted_item_type: String

var colliding_characters = []
var tile_map: TileMap
var tile_map_node: Node

onready var base_z_index: int = z_index
onready var interaction_area: Area2D = find_node("InteractionArea")
onready var tween: Tween = $Tween


func _ready():
	if has_node("Variants"):
		for map in $Variants.get_children():
			if map.visible:
				tile_map_node = map
				break
	else:
		tile_map_node = get_node("TileMap")

	tile_map = tile_map_node


func on_body_enter(body: PhysicsBody2D):
	if body == MoveTarget:
		Player.item_under_target = self

	if body == Player && Player.item_under_target == self && Player.last_movement_from_mouse:
		interact()


func on_body_exit(body: PhysicsBody2D):
	if body == MoveTarget && Player.item_under_target == self:
		Player.item_under_target = null


func _exit_tree():
	if Player.item_under_target == self:
		Player.item_under_target = null


func set_collision_mask_on_interaction_area(mask: int):
	if interaction_area != null:
		interaction_area.collision_mask = mask


func interact():
	print("base interact with item")


func on_walk_behind_trigger_enter(body: PhysicsBody2D):
	base_z_index = z_index

	var character: bool = "user_id" in body
	var player: bool = body == Player

	if ! character:
		return

	colliding_characters.append(character)

	if player != false:
		tween.interpolate_property(
			tile_map_node,
			"modulate",
			tile_map.modulate,
			Color(1, 1, 1, 0.3),
			0.33,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
		)

		var light: LightOccluder2D = find_node("LightOccluder2D")

		if light != null:
			light.hide()

	z_index = base_z_index + 3

	tween.start()


func on_walk_behind_trigger_exit(body):
	var character: bool = "user_id" in body
	var player: bool = body == Player

	if ! character:
		return

	if colliding_characters.has(character):
		colliding_characters.erase(character)

	if colliding_characters.size() == 0:
		z_index = base_z_index

	if player != false:
		tween.stop(tile_map_node)

		tween.interpolate_property(
			tile_map_node,
			"modulate",
			tile_map.modulate,
			Color(1, 1, 1, 1),
			0.33,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
		)

		if tween.is_inside_tree():
			tween.start()

		var light = find_node("LightOccluder2D")

		if light != null:
			light.show()


func place_crafted_item_on_farm_grid():
	var farm_grid = Player.current_farm_grid

	if is_crafted == false || farm_grid == null:
		return

	var grid_position = MoveTarget.get_current_farm_grid_tile()

	if farm_grid.is_user_owner() == false:
		TPLG.ui.show_toast("You can't put crafted items on someone else's farm.")
		return

	if farm_grid.has_farm_item(grid_position):
		return

	var item_hash = InventoryItems.get_hash_from_int(
		InventoryItems.get_int_from_name("Crafted_%s" % [crafted_item_type])
	)

	MatchEvent.farming(
		{
			"type": FarmEvent.PLACE_CRAFTED_ITEM,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(position.x),
			"y": String(position.y),
			"metadata": item_hash
		}
	)


#       if (SessionManager.match == null) {
#         if (await farmData.PlaceCraftedItem(
#           gridPosition,
#           itemHash
#         )) {
#           await InventoryController.instance.bag.ReloadBag();
#         } else {
#           new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#         }
#       } else {
#         InventoryController.instance.bag.RemoveItemLocally(InventoryItemIDHelper.GetEnum(itemHash));
#       }
#     }


func remove_crafted_item_on_farm_grid():
	if is_crafted == false || Player.current_farm_grid == null:
		return

	var farm_grid = Player.current_farm_grid
	var item_hash = InventoryItems.get_hash_from_int(
		InventoryItems.get_int_from_name("Crafted_%s" % [crafted_item_type])
	)

	if farm_grid.is_user_owner() == false:
		TPLG.ui.show_toast("You can't steal crafted items. Tsk!")
		return

	MatchEvent.farming(
		{
			"type": FarmEvent.REMOVE_CRAFTED_ITEM,
			"avatar": SaveData.current_avatar_key,
			"farm_owner_id": farm_grid.owner_id,
			"farm_owner_avatar": farm_grid.owner_avatar_name,
			"farm_collection": farm_grid.collection_name,
			"x": String(position.x / 16),
			"y": String(position.y / 16),
			"metadata": item_hash
		}
	)

# if (SessionManager.match == null) {
#   if (await farmData.RemoveCraftedItem(
#     gridPosition,
#     itemHash
#   )) {
#     await InventoryController.instance.bag.ReloadBag();
#   } else {
#     new DataResetEvent(new DataResetEventArgs(SessionManager.GetUserId()));
#   }
# } else {
#   InventoryController.instance.bag.AddItemLocally(InventoryItemIDHelper.GetEnum(itemHash));
# }
