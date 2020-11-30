extends Node

enum { STONE = 0, WEED = 1, TREE = 2, TALL_GRASS = 3 }

onready var type_to_scene_map = {
	STONE: ResourceLoader.load("res://Scenes/Items/EnvironmentItems/ForageableItems/Stone.tscn"),
	WEED: ResourceLoader.load("res://Scenes/Items/EnvironmentItems/ForageableItems/Weed.tscn"),
	TREE: ResourceLoader.load("res://Scenes/Items/EnvironmentItems/ForageableItems/Tree.tscn"),
	TALL_GRASS:
	ResourceLoader.load("res://Scenes/Items/EnvironmentItems/ForageableItems/TallGrass.tscn"),
}
