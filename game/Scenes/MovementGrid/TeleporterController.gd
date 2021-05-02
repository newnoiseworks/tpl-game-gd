extends Area2D

export var scene_to_load: String
export var exit_enabled: bool

var last_scene


func on_body_enter(body):
	if body == Player && exit_enabled:
		TPLG.ui.show_loading_dialog()
		yield(MatchManager.leave_match(), "completed")

		TPLG.base_change_scene("res://%s" % [scene_to_load])


func on_body_exit(body):
	if body == Player:
		exit_enabled = true
