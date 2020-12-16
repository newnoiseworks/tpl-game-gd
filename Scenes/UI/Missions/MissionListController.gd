extends PanelContainer

var row_scene = ResourceLoader.load("res://Scenes/UI/Missions/MissionRow.tscn")

onready var list = $ItemList


func _ready():
	var missionData = yield(SaveData.load("missionData"), "completed")

	if missionData == null && missionData.missions == null:
		return

	for mission in missionData.missions:
		if mission.finished == 0:
			var mission_row = row_scene.instance()
			mission_row.title = mission.title
			list.call_deferred("add_child", mission_row)
