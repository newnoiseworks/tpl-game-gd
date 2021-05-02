extends "res://Scenes/MovementGrid/TeleporterController.gd"

export var enabled: bool

var user_id_to_join: String
var user_avatar_to_join: String


func on_body_enter(body: PhysicsBody2D):
	if enabled == false || exit_enabled == false:
		return

	scene_to_load = "RootScenes/Farm/Farm.tscn"
	exit_enabled = true

	TPLG.current_farm = {
		"user_id": user_id_to_join,
		"user_avatar": user_avatar_to_join,
	}

	.on_body_enter(body)
