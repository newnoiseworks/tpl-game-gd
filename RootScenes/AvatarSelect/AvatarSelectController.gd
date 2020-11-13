extends Node

onready var avatar_scene: PackedScene = ResourceLoader.load(
	"res://RootScenes/AvatarSelect/Avatar.tscn"
)


func _ready():
	yield(SessionManager.login("wow@wow.com", "password"), "completed")
	yield(SessionManager.get_profile_data(), "completed")
	draw_from_data(SessionManager.profile_data)


func draw_from_data(data):
	var avatar_container: HBoxContainer = find_node("AvatarContainer")

	for avatar in data.avatars:
		add_avatar(avatar, avatar_container)


func add_avatar(avatar, avatar_container):
	var avatar_instance = avatar_scene.instance()
	avatar_container.add_child(avatar_instance)
	avatar_instance.set_data(avatar)
