extends KinematicBody2D

onready var map: TileMap = find_node("MovementGridTile")


func _ready():
	get_parent().call_deferred("remove_child", self)


func get_current_farm_grid_tile(grid_position = null):
	if grid_position == null:
		grid_position = Player.current_farm_grid.position

	return world_to_map(position) - world_to_map(grid_position)


func get_tile_position():
	return world_to_map(position)


func world_to_map(position: Vector2):
	if map != null && is_inside_tree():
		return map.world_to_map(position)


func set_target_tile_from(position: Vector2):
	if is_inside_tree():
		show()
		self.position = world_to_map(position) * 16
