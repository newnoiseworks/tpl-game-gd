extends "res://Utils/GameConfig.gd"

signal ui_message_dialog(message)

signal base_change_scene(scene_path)


func show_message(message: String):
	emit_signal("ui_message_dialog", message)


func base_change_scene(scene_path: String):
	emit_signal("base_change_scene", scene_path)
