extends PanelContainer

var row_scene = ResourceLoader.load("res://Scenes/UI/Missions/MissionRow.tscn")

onready var list = $ItemList


func _ready():
	var mission_data = yield(SaveData.load("missionData"), "completed")

	if mission_data == null && mission_data.missions == null:
		return

	for mission in mission_data.missions:
		if mission.finished == 0:
			var mission_details = MissionList.list[mission.key]
			var mission_row = row_scene.instance()
			mission_row.title = mission_details.title
			list.call_deferred("add_child", mission_row)
