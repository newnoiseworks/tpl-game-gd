extends Control

onready var game_viewport: Viewport = find_node("GameViewport")


func _ready():
	TPLG.connect("base_change_scene", self, "change_scene")


func change_scene(scene_path: String, args: Dictionary, reset_vp: bool = false):
	for child in game_viewport.get_children():
		game_viewport.call_deferred("remove_child", child)

	add_scene_after_one_frame(scene_path, args)

	if reset_vp:
		var vp = get_node("/root/BaseViewports/GameViewportContainer/GameViewport/").get_children()[0].get_viewport()

		if vp == null:
			return

		vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y))
		vp.size_override_stretch = true

		get_node("/root/BaseViewports/UIViewportContainer/UIViewport/UI").queue_free()


func add_scene_after_one_frame(scene_path: String, args: Dictionary):
	call_deferred("add_scene", scene_path, args)


func add_scene(scene_path: String, args: Dictionary):
	var scene: Node = ResourceLoader.load(scene_path).instance()

	for key in args.keys():
		scene[key] = args[key]

	game_viewport.add_child(scene)
