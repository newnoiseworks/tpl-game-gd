extends VBoxContainer

var user_id: String
var farm_collection: String

var data
var perms_dict: Dictionary = {}
var perms

onready var permission_row_scene = ResourceLoader.load(
	"res://Scenes/UI/FarmPermissions/FarmPermissionOption.tscn"
)
onready var items: VBoxContainer = find_node("ItemList")


func _ready():
	data = yield(SaveData.load(farm_collection), "completed")

	if data == null:
		data = {}

	if ! data.has("defaultPermissions"):
		data.defaultPermissions = {"till": 0, "harvest": 0, "plant": 0, "forage": 0, "water": 0}

	if ! data.has("permCollection"):
		data.permCollection = {}

	if ! data.permCollection.has(user_id):
		data.permCollection[user_id] = data.defaultPermissions

	perms = data.permCollection[user_id]

	perms_dict = {
		"till": perms.till,
		"harvest": perms.harvest,
		"plant": perms.plant,
		"forage": perms.forage,
		"water": perms.water
	}

	for key in perms_dict:
		var permission_row = permission_row_scene.instance()
		print(perms_dict[key])
		permission_row.toggle_on = perms_dict[key] == 1
		permission_row.label_text = key
		permission_row.connect("permission_toggled", self, "toggle")
		items.call_deferred("add_child", permission_row)


func toggle(perm_type: String, on: bool):
	var permission: int = 1 if on else 0

	if perms_dict.has(perm_type):
		match perm_type:
			"plant":
				perms.plant = permission
			"harvest":
				perms.harvest = permission
			"till":
				perms.till = permission
			"water":
				perms.water = permission
			"forage":
				perms.forage = permission


func save():
	data.permCollection[user_id] = perms
	yield(SaveData.save(data, farm_collection), "completed")
	MatchEvent.farm_permission_update("true")
