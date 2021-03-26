extends Control

onready var game_viewport: Viewport = find_node("GameViewport")
onready var game_viewport_container: ViewportContainer = find_node("GameViewportContainer")
onready var tween = $Tween


func _ready():
	TPLG.connect("base_change_scene", self, "_change_scene")


func _fade_game_viewport(out: bool = false, time: float = 0.33):
	tween.interpolate_property(
		game_viewport_container,
		"modulate",
		game_viewport_container.modulate,
		Color(1, 1, 1, 0) if out else Color(1, 1, 1, 1),
		time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		0 if out else .33
	)

	tween.start()

	yield(tween, "tween_completed")


func _change_scene(
	scene_path: String, args: Dictionary, reset_vp: bool = false, update_inventory: bool = true
):
	yield(_fade_game_viewport(true), "completed")

	if Player.is_inside_tree():
		Player.get_parent().call_deferred("remove_child", Player)

	if MoveTarget.is_inside_tree():
		MoveTarget.get_parent().call_deferred("remove_child", MoveTarget)

	if TPLG.inventory && update_inventory:
		TPLG.inventory.bag.reload_and_redraw_data()

	for child in game_viewport.get_children():
		game_viewport.call_deferred("remove_child", child)

	_add_scene_after_one_frame(scene_path, args)

	if reset_vp:
		var vp = get_node("/root/BaseViewports/GameViewportContainer/GameViewport/").get_children()[0].get_viewport()

		if vp == null:
			return

		vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y))
		vp.size_override_stretch = true

		get_node("/root/BaseViewports/UIViewportContainer/UIViewport/UI").queue_free()

	yield(_fade_game_viewport(), "completed")


func _add_scene_after_one_frame(scene_path: String, args: Dictionary):
	call_deferred("_add_scene", scene_path, args)


func _add_scene(scene_path: String, args: Dictionary):
	var scene: Node = ResourceLoader.load(scene_path).instance()

	for key in args.keys():
		if key in scene:
			scene[key] = args[key]

	game_viewport.add_child(scene)
