extends Control

onready var game_viewport: Viewport = find_node("GameViewport")


func _ready():
	TPLG.connect("base_change_scene", self, "change_scene")


func change_scene(scene_path: String, args: Dictionary):
	for child in game_viewport.get_children():
		child.queue_free()

	call_deferred("add_scene_after_one_frame", scene_path, args)


func add_scene_after_one_frame(scene_path: String, args: Dictionary):
	call_deferred("add_scene", scene_path, args)


func add_scene(scene_path: String, args: Dictionary):
	var scene: Node = ResourceLoader.load(scene_path).instance()

	for key in args.keys():
		scene[key] = args[key]

	game_viewport.add_child(scene)
