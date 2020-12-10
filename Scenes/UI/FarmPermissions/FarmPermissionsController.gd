extends WindowDialog

var user_id: String
var username: String
var avatar_name: String

onready var label: RichTextLabel = find_node("Label")
onready var permissions_options_scene: PackedScene = ResourceLoader.load(
	"res://Scenes/UI/FarmPermissions/FarmPermissionsOptionList.tscn"
)
onready var tab_container: TabContainer = find_node("TabContainer")


func _ready():
	TPLG.set_farm_perms(self)


func popup_with_user(_user_id: String):
	user_id = _user_id
	username = RealmManager.user_id_to_username_map[user_id]
	avatar_name = RealmManager.user_id_to_avatar_map[user_id]

	for child in tab_container.get_children():
		child.queue_free()

	label.text = "%s (%s)" % [avatar_name, username]

	var farm_options_scene = permissions_options_scene.instance()
	farm_options_scene.user_id = user_id
	farm_options_scene.farm_collection = "town0FarmGridPermissions"
	farm_options_scene.name = "Home Farm"

	tab_container.add_child(farm_options_scene)

	var community_farm_scene = permissions_options_scene.instance()
	community_farm_scene.user_id = user_id
	community_farm_scene.farm_collection = "town0CommunityFarmPermissions"
	community_farm_scene.name = "Community Farm"

	tab_container.add_child(community_farm_scene)

	popup_centered()
