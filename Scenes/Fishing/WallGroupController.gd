extends Node2D

var wall_pair_scene = ResourceLoader.load("res://Scenes/Fishing/WallPair.tscn")

onready var finish = find_node("FinishBar")


func _ready():
	var rng = TPLG.rng
	var wall_count = rng.randi_range(5, 15)

	for i in range(wall_count):
		var wall = wall_pair_scene.instance()

		wall.position.x = 192 + (i * 64)
		wall.position.y = rng.randf_range(-25.0, 25.0)
		add_child(wall)

	finish.position.x = 192 + (wall_count * 64) + 4


func _physics_process(_delta):
	position += Vector2(-2, 0)
