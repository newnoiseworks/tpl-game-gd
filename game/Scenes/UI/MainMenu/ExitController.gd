extends Control


func change_avatar():
	yield(MatchManager.leave_match(), "completed")
	yield(RealmManager.leave_realm(), "completed")
	TPLG.base_change_scene("res://RootScenes/AvatarSelect/AvatarSelect.tscn", {}, true)


func logout():
	yield(MatchManager.leave_match(), "completed")
	yield(RealmManager.leave_realm(), "completed")
	SessionManager.client = null
	TPLG.base_change_scene("res://RootScenes/Authentication/Authentication.tscn", {}, true)


func quit():
	get_tree().quit()
