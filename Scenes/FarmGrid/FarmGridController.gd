extends YSort

export var tile_width: int
export var tile_height: int
export var collection_name: String

var owner_id: String
var owner_avatar_name: String
var data: Dictionary
var farm_permissions: Dictionary
var plant_scenes: Dictionary = {}
var forage_item_scenes = {}
var crafted_item_scenes = {}

onready var ground_map: TileMap = find_node("Ground")
onready var tweener: Tween = find_node("Tween")
onready var tile_adjuster: Node = $TileAdjuster


func _ready():
	MatchEvent.connect("data_reset", self, "reload_data_on_reset_event")


func _exit_tree():
	MatchEvent.disconnect("data_reset", self, "reload_data_on_reset_event")


func on_body_enter(body: Node):
	if body == MoveTarget:
		Player.current_farm_grid = self


func on_body_exit(body: Node):
	if (
		body == MoveTarget
		&& Player != null
		&& Player.current_farm_grid != null
		&& Player.current_farm_grid == self
	):
		Player.current_farm_grid = null


func load_farm(user_id: String, user_avatar: String, collection: String = ""):
	owner_id = user_id
	owner_avatar_name = user_avatar
	if collection != "":
		collection_name = collection

	if user_id == SessionManager.session.user_id:
		yield(
			SessionManager.rpc_async(
				"farm_grid.cleanup",
				JSON.print(
					{
						"farm_owner_id": user_id,
						"farm_owner_avatar": user_avatar,
						"farm_collection": collection_name,
					}
				)
			),
			"completed"
		)

	yield(load_data(), "completed")

	show()

	setup_collider()


func is_user_owner():
	return owner_id == SessionManager.session.user_id


func setup_collider():
	var collision_shape = find_node("CollisionShape2D")
	collision_shape.position = Vector2(tile_width * 16, tile_height * 16) / 2
	var shape = collision_shape.shape
	shape.extents = Vector2(tile_width * 16, tile_height * 16) / 2
	collision_shape.shape = shape


func reset_dirt():
	for row_key in data.groundTiles:
		var row = data.groundTiles[row_key]
		for tile_key in row:
			var tile = row[tile_key]
			if tile != null:
				data.groundTiles[row_key][tile_key] = "tilled"

	ground_map.clear()


func unset_farm(full_reset: bool = false):
	ground_map.clear()

	reset_dirt()

	for item_key in plant_scenes:
		plant_scenes[item_key].queue_free()

	plant_scenes.clear()

	for item_key in forage_item_scenes:
		forage_item_scenes[item_key].queue_free()

	forage_item_scenes.clear()

	for item_key in crafted_item_scenes:
		crafted_item_scenes[item_key].queue_free()

	crafted_item_scenes.clear()

	if full_reset:
		owner_avatar_name = ""
		owner_id = ""
		data = {}


func reload_data_on_reset_event(_args, _presence):
	print_debug("Unsetting farm grid")
	unset_farm()
	yield(load_data(), "completed")
	call_deferred("draw_plants_from_data")


func load_data():
	data = yield(SaveData.load(collection_name, owner_avatar_name, owner_id), "completed")

	if ! data.has("plants"):
		data.plants = []

	if ! data.has("craftedItems"):
		data.craftedItems = []

	if ! data.has("groundTiles"):
		data.groundTiles = {}

	call_deferred("draw_things_from_data")


func draw_things_from_data():
	draw_ground_from_data()
	draw_forage_items_from_data()
	draw_crafted_items_from_data()


func draw_ground_from_data():
	if ! data.has("groundTiles"):
		return

	var tilled_tiles = []

	for row_key in data.groundTiles:
		var row = data.groundTiles[row_key]
		for tile_key in row:
			var pos = Vector2(int(tile_key), int(row_key))
			var tile = row[tile_key]

			if tile == "tilled":
				tilled_tiles.append(pos)
				continue

			var tile_idx: int = get_tile_index_from_name(ground_map, tile)

			if tile_idx == -1:
				continue

			ground_map.set_cellv(pos, tile_idx)

	for pos in tilled_tiles:
		tile_adjuster.till_tiled_dirt(ground_map, pos, data)
		pass


func draw_crafted_items_from_data():
	for item in data.craftedItems:
		add_crafted_item_to_grid(item)


func draw_forage_items_from_data():
	for item in data.forageItems:
		if item.health > 0:
			add_forage_item_to_grid(item)


func draw_plants_from_data():
	if ! data.has("plants"):
		return

	for plant in data.plants:
		add_plant_to_grid(plant)


func get_ground_map_tilename_from_position(grid_position):
	return get_tilename_from_position(ground_map, grid_position)


func on_farming_event(farm_event):
	farm_event.position = Vector2(farm_event.x, farm_event.y)

	match int(farm_event.type):
		FarmEvent.PLANT:
			add_plant_from_event(farm_event)
		FarmEvent.TILL:
			till_soil(farm_event)
		FarmEvent.HARVEST:
			harvest_crop(farm_event)
		FarmEvent.FORAGE:
			forage_item(farm_event)
		FarmEvent.PLACE_CRAFTED_ITEM:
			place_crafted_item(farm_event)
		FarmEvent.REMOVE_CRAFTED_ITEM:
			remove_crafted_item(farm_event)
		FarmEvent.DETILL:
			detill_soil(farm_event)
		FarmEvent.WATER:
			water_plant(farm_event)


func get_permissions(user_id = ""):
	if user_id == "":
		user_id = SessionManager.session.user_id

	if farm_permissions.has("permCollection") && farm_permissions.permCollection.has(user_id):
		return farm_permissions.permCollection[user_id]

	return farm_permissions.defaultPermissions


func has_farm_item(position):
	return (
		plant_scenes.has(position)
		|| forage_item_scenes.has(position)
		|| crafted_item_scenes.has(position)
	)


func is_tile_tilled(position: Vector2):
	return (
		data.groundTiles.has(String(position.y))
		&& data.groundTiles[String(position.y)].has(String(position.x))
		&& data.groundTiles[String(position.y)][String(position.x)] != null
	)


func water_plant(farm_event: Dictionary):
	var plant = plant_scenes[farm_event.position]

	if plant != null:
		plant.water()


func remove_crafted_item(farm_event: Dictionary):
	var crafted_item_to_remove

	for i in data.craftedItems:
		var i_pos = Vector2(i.x, i.y)

		if i_pos == farm_event.position && i.type == farm_event.metadata:
			crafted_item_to_remove = i

	data.craftedItems.erase(crafted_item_to_remove)
	crafted_item_scenes[farm_event.position].queue_free()
	crafted_item_scenes.erase(farm_event.position)


func place_crafted_item(farm_event: Dictionary):
	var crafted_item_to_add = {
		"x": farm_event.position.x, "y": farm_event.position.y, "type": farm_event.metadata
	}

	if data.craftedItems is Dictionary && data.craftedItems.size() == 0:
		data.craftedItems = []

	data.craftedItems.append(crafted_item_to_add)
	add_crafted_item_to_grid(crafted_item_to_add)


func forage_item(farm_event: Dictionary):
	var item

	for i in data.forageItems:
		var i_position = Vector2(i.x, i.y)
		if i_position == farm_event.position && i.type == int(farm_event.metadata):
			item = i

	if item.health > 0:
		item.health -= item.damageOnHit
		var i_pos = Vector2(item.x, item.y)
		var forage_item = forage_item_scenes[i_pos]

		if item.health <= 0:
			spawn_drops(forage_item, item)
			forage_item.queue_free()
			forage_item_scenes.erase(farm_event.position)
			# TPLNavigation2DController.instance.SetupNav();
		else:
			tweener.interpolate_property(
				forage_item,
				"position",
				forage_item.position + Vector2(1, 0),
				forage_item.position,
				0.15,
				Tween.TRANS_ELASTIC,
				Tween.EASE_IN
			)
			tweener.start()


func spawn_drops(forage_item, forage_item_data):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for drop_item in forage_item_data.dropItems:
		for _i in range(drop_item.count):
			var item_scene: PackedScene = TPLG.inventory.bag.equiptable_item_scenes[InventoryItems.get_int_from_hash(
				drop_item.type
			)]
			var instanced_drop = item_scene.instance()
			instanced_drop.forage_item_data = forage_item_data
			instanced_drop.farm_owner_id = owner_id
			instanced_drop.farm_owner_avatar = owner_avatar_name
			instanced_drop.farm_owner_collection = collection_name

			var position = (
				forage_item.position
				+ Vector2(rng.randi_range(-24, 24), rng.randi_range(-24, 24))
			)
			instanced_drop.position = position

			forage_item.get_parent().call_deferred("add_child", instanced_drop)


func till_soil(farm_event):
	var grid_position = farm_event.position

	tile_adjuster.till_tiled_dirt(ground_map, grid_position, data)


func detill_soil(farm_event):
	var grid_position = farm_event.position

	data.groundTiles[String(grid_position.y)].erase(String(grid_position.x))

	if data.groundTiles[String(grid_position.y)].size() == 0:
		data.groundTiles.erase(String(grid_position.y))

	reset_dirt()
	draw_ground_from_data()


func harvest_crop(harvest_event):
	var grid_position: Vector2 = harvest_event.position

	var plant_data

	for p in data.plants:
		var p_position = Vector2(p.x, p.y)
		if p_position == grid_position && p.plantType == harvest_event.metadata:
			plant_data = p

	var plant = plant_scenes[harvest_event.position]

	plant_scenes.erase(harvest_event.position)

	data.plants.erase(plant_data)

	plant.queue_free()


func add_plant_from_event(farm_event: Dictionary):
	var plant_hash_id = PlantData.seed_to_plant_hash_map[farm_event.metadata]
	var initial_water_history = []

	for _i in range(InventoryItems.plant_growth_stages[plant_hash_id].size()):
		initial_water_history.append(0)

	var plant_to_add = {
		"x": farm_event.position.x,
		"y": farm_event.position.y,
		"createdAt": GameTime.get_current_timestamp() * 1000,
		"plantType": plant_hash_id,
		"waterHistory": initial_water_history
	}

	if data.empty() || data.plants is Dictionary:
		data.plants = []

	data.plants.append(plant_to_add)
	add_plant_to_grid(plant_to_add)


func add_plant_to_grid(plant_data: Dictionary):
	var plant_scene = PlantData.item_type_to_plant_scene_map[plant_data.plantType]
	var instanced_plant = plant_scene.instance()

	instanced_plant.data = plant_data
	instanced_plant.created_at = plant_data.createdAt
	instanced_plant.position = Vector2(plant_data.x, plant_data.y) * 16

	plant_scenes[Vector2(plant_data.x, plant_data.y)] = instanced_plant

	call_deferred("add_child", instanced_plant)


func add_crafted_item_to_grid(item: Dictionary):
	var item_scene = TPLG.inventory.bag.equiptable_item_scenes[InventoryItems.get_int_from_hash(
		item.type
	)]
	var instanced_item = item_scene.instance()
	instanced_item.position = Vector2(item.x, item.y) * 16

	if instanced_item.on_ground:
		find_node("GroundedItems").call_deferred("add_child", instanced_item)
	else:
		call_deferred("add_child", instanced_item)

	crafted_item_scenes[instanced_item.position / 16] = instanced_item


func add_forage_item_to_grid(item: Dictionary):
	var item_scene = ForageItems.type_to_scene_map[int(item.type)]
	var instanced_forage_item = item_scene.instance()
	instanced_forage_item.position = Vector2(item.x, item.y) * 16

	for node in instanced_forage_item.get_node("Variants").get_children():
		node.hide()

	var ivariant: String = String(item.variant + 1) if item.variant > 0 else ""
	var flipped: String = "Flipped" if item.flippedX else ""

	var tile: TileMap = instanced_forage_item.get_node("Variants/%sTileMap%s" % [flipped, ivariant])

	tile.show()

	forage_item_scenes[Vector2(item.x, item.y)] = instanced_forage_item
	call_deferred("add_child", instanced_forage_item)


func get_tilename_from_position(map: TileMap, grid_position: Vector2):
	var existing_tile: int = map.get_cellv(grid_position)

	if existing_tile == -1:
		return null

	return map.tile_set.tile_get_name(existing_tile)


func get_tile_index_from_name(map: TileMap, tilename: String):
	var tile = map.tile_set.find_tile_by_name(tilename)
	return tile
