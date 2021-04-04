extends "res://Utils/GameConfig.gd"

signal ui_message_dialog(message)

signal base_change_scene(scene_path, args, reset_vp)

var current_root_scene

var current_farm_grids = []

var current_farm = {"user_id": "", "user_avatar": ""}

var last_scene = ""

var last_position_in_last_scene: Vector2

var inventory

var store

var dialogue

var farm_perms

var ui

var wallet

var reatomizer

var weather

var ui_scene: PackedScene = ResourceLoader.load("res://Scenes/UI/UI.tscn")

onready var rng = RandomNumberGenerator.new()


func set_ui_scene():
	get_node("/root/BaseViewports/UIViewportContainer/UIViewport").call_deferred(
		"add_child", ui_scene.instance()
	)


func set_sky(_sky):
	weather.sky = _sky
	TPLG.weather.execute_weather_change()


func set_weather(_weather):
	weather = _weather


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


func base_change_scene(scene_path: String, args: Dictionary = {}, reset_vp: bool = false):
	emit_signal("base_change_scene", scene_path, args, reset_vp)

	if current_root_scene != null && current_root_scene.save_as_last_scene:
		last_scene = current_root_scene.filename.replace("res://", "").replace(".tscn", "").replace(
			"RootScenes/", ""
		)

		last_position_in_last_scene = Player.position


func goto_last_scene():
	base_change_scene("res://RootScenes/%s.tscn" % last_scene)
