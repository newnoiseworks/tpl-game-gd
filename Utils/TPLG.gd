extends "res://Utils/GameConfig.gd"

signal ui_message_dialog(message)

signal base_change_scene(scene_path, args)

var current_farm_grids = []

var last_scene = ""

var inventory

var store

var dialogue

var farm_perms

var ui

var wallet

var reatomizer

var ui_scene: PackedScene = ResourceLoader.load("res://Scenes/UI/UI.tscn")


func set_ui_scene():
	get_node("/root/BaseViewports/UIViewportContainer/UIViewport").call_deferred(
		"add_child", ui_scene.instance()
	)


func set_reatomizer(_reatomizer):
	reatomizer = _reatomizer


func set_wallet(_wallet):
	wallet = _wallet


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


func base_change_scene(scene_path: String, args: Dictionary = {}):
	emit_signal("base_change_scene", scene_path, args)
