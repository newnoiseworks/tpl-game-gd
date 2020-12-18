extends PanelContainer

var row_scene = ResourceLoader.load("res://Scenes/UI/Missions/MissionRow.tscn")

onready var list = $ItemList

var current_missions = []


func _ready():
	var mission_data = SessionManager.mission_data

	if mission_data == null && mission_data.missions == null:
		return

	for mission in mission_data.missions:
		if mission.finished == 0:
			var mission_details = MissionList.list[mission.key]
			mission_details.key = mission.key
			current_missions.append(mission_details)
			var mission_row = row_scene.instance()
			mission_row.title = mission_details.title
			list.call_deferred("add_child", mission_row)
