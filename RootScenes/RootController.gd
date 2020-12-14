extends Node2D

export var scene_name: String

# var debug_window_scene: PackedScene = ResourceLoader.load("res://Scenes/UI/DebugWindow.tscn")
# var teleporter_scene: PackedScene = ResourceLoader.load("res://Scenes/MovementGrid/Teleporter.tscn")

var zoom_offset: float = 3


func _ready():
	# add_child(debug_window_scene.instance())
	window_size_setup()


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


# WELP: Kind of a weird place to put this but need a non static context that exists across scenes
func join_farm_match(_match_id: String, _match_label: String):
	var _parts = _match_label.split("//")
#       string[] parts = matchLabel.Split("//");

#       FarmController.userIdToJoin = parts[1];
#       FarmController.userAvatarToJoin = parts[2];
#       FarmController.joinMatchOnReady = true;
#       TeleporterController.lastScene = null;

#       // WELP: The below line should work without producing a litany of errors...
#       // GetTree().ChangeScene("res://RootScenes/Farm/Farm.tscn");

#       // WELP: ... but this is the code that doesn't produce a bunch of errors. Go figure, maybe flip and see if it goes away on an upgrade.
#       TeleporterController tp = (TeleporterController)teleporterScene.Instance();
#       tp.sceneToLoad = "RootScenes/Farm/Farm.tscn";
#       tp.exitEnabled = true;
#       NodeManager.ScheduleAdd(PlayerController.instance, tp);
#     }
# }
