extends "res://Utils/GameConfig.gd"

signal ui_message_dialog(message)

signal base_change_scene(scene_path)

var inventory

var store

var dialogue

var farm_perms

var ui


func set_ui(_ui):
	ui = _ui


func set_farm_perms(_perms):
	farm_perms = _perms


func set_dialogue(_dialogue):
	dialogue = _dialogue


func set_store(_store):
	store = _store


func set_inventory(_inventory):
	inventory = _inventory


func show_message(message: String):
	emit_signal("ui_message_dialog", message)


func base_change_scene(scene_path: String):
	emit_signal("base_change_scene", scene_path)
