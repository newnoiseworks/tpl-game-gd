extends Control

onready var game_viewport: Viewport = find_node("GameViewport")


func _ready():
	TPLG.connect("base_change_scene", self, "change_scene")


func change_scene(scene_path: String):
	for child in game_viewport.get_children():
		child.queue_free()

	call_deferred("add_scene", scene_path)


func add_scene(scene_path: String):
	var scene: Node = ResourceLoader.load(scene_path).instance()

	game_viewport.add_child(scene)
