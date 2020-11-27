extends "res://Utils/GameConfig.gd"

signal ui_message_dialog(message)

signal base_change_scene(scene_path)

var inventory

var store


func set_store(_store):
	store = _store


func set_inventory(_inventory):
	inventory = _inventory


func show_message(message: String):
	emit_signal("ui_message_dialog", message)


func base_change_scene(scene_path: String):
	emit_signal("base_change_scene", scene_path)
