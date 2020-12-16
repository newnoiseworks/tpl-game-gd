extends PanelContainer

var row_scene = ResourceLoader.load("res://Scenes/UI/Missions/MissionRow.tscn")

onready var list = $ItemList


func _ready():
	for title in ["This is a mission", "This is another mission"]:
		var mission_row = row_scene.instance()
		mission_row.title = title
		list.call_deferred("add_child", mission_row)
