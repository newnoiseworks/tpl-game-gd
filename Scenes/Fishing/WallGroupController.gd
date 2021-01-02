extends Node2D

var wall_pair_scene = ResourceLoader.load("res://Scenes/Fishing/WallPair.tscn")

onready var finish = find_node("FinishBar")

var distance_between_walls = 128


func _ready():
	var rng = TPLG.rng
	var wall_count = rng.randi_range(5, 15)

	for i in range(wall_count):
		var wall = wall_pair_scene.instance()

		wall.position.x = 192 + (i * distance_between_walls)
		wall.position.y = rng.randf_range(-50.0, 50.0)
		add_child(wall)

	finish.position.x = 192 + ((wall_count - 0.5) * distance_between_walls)


func _physics_process(_delta):
	position += Vector2(-2, 0)
