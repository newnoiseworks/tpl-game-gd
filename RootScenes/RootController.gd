extends Node2D

export var scene_name: String

# var debug_window_scene: PackedScene = ResourceLoader.load("res://Scenes/UI/DebugWindow.tscn")
# var teleporter_scene: PackedScene = ResourceLoader.load("res://Scenes/MovementGrid/Teleporter.tscn")

var zoom_offset: float = 3

var mission_scenes = {}
var mission_dialogue_options = {}

onready var mission_launcher_node = find_node("MissionLauncher")


func _ready():
	# add_child(debug_window_scene.instance())
	window_size_setup()
	mission_setup()
	TPLG.current_root_scene = self


func mission_setup():
	if mission_launcher_node == null:
		return

	var current_missions = TPLG.ui.mission_list.current_missions
	for mission in current_missions:
		if mission.key in mission_scenes.keys():
			var mission_scene = ResourceLoader.load(mission_scenes[mission.key])
			mission_launcher_node.call_deferred("add_child", mission_scene.instance())


func window_size_setup():
	OS.min_window_size = Vector2(1280, 720)
	get_tree().root.connect("size_changed", self, "on_window_resize")


func on_window_resize():
	var vp = get_viewport()

	if vp == null:
		return

	vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y) / zoom_offset)
	vp.size_override_stretch = true

	if Player.is_inside_tree():
		var camera: Camera2D = Player.camera
		var width: int = int(
			abs(camera.limit_left) * zoom_offset + abs(camera.limit_right) * zoom_offset
		)

		if OS.window_size.x > width:
			camera.offset = Vector2(int((OS.window_size.x - width) / 2) / zoom_offset, 0)
		else:
			camera.offset = Vector2()
