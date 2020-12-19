extends PanelContainer

var row_scene = ResourceLoader.load("res://Scenes/UI/Missions/MissionRow.tscn")

onready var list = find_node("ItemList")

var current_missions = []


func _ready():
	_draw_missions()


func get_completed_mission_keys():
	var missions = []

	for mission_status in SessionManager.mission_data.missions:
		if mission_status.finished == 1:
			missions.append(mission_status.key)

	return missions


func get_current_mission_keys():
	var missions = []

	for mission_status in SessionManager.mission_data.missions:
		if mission_status.finished == 0:
			missions.append(mission_status.key)

	return missions


func finish_mission(key: String):
	yield(
		SessionManager.rpc_async(
			"missions.complete", JSON.print({"key": key, "avatar": SaveData.current_avatar_key})
		),
		"completed"
	)


func start_mission(key: String):
	yield(
		SessionManager.rpc_async(
			"missions.start", JSON.print({"key": key, "avatar": SaveData.current_avatar_key})
		),
		"completed"
	)


func reload_missions():
	yield(SessionManager.load_mission_data(), "completed")

	for mission_status in SessionManager.mission_data.missions:
		var found_mission = false

		for mission_row in list.get_children():
			if mission_row.key == mission_status.key:
				found_mission = true
				if mission_row.finished == false && mission_status.finished == 1:
					mission_row.mark_as_finished()
					for cur_mission in current_missions:
						if cur_mission.key == mission_status.key:
							current_missions.erase(cur_mission)

		if mission_status.finished == 0 && ! found_mission:
			_add_unfinished_mission(mission_status.key)


func _draw_missions():
	var mission_data = SessionManager.mission_data

	if mission_data == null && mission_data.missions == null:
		return

	current_missions = []

	for mission in mission_data.missions:
		if mission.finished == 0:
			_add_unfinished_mission(mission.key)


func _add_unfinished_mission(key):
	var mission_details = MissionList.list[key]
	mission_details.key = key
	current_missions.append(mission_details)
	var mission_row = row_scene.instance()
	mission_row.title = mission_details.title
	mission_row.key = mission_details.key
	list.call_deferred("add_child", mission_row)
