extends Control

export var is_creating: bool = false

const OUTFIT_LIMIT: int = 3

onready var hair_label: Label = find_node("HaircutLabel")
onready var top_label: Label = find_node("TopLabel")
onready var bottom_label: Label = find_node("BottomLabel")
onready var mannequin = find_node("Farmer")


func _ready():
	if is_creating:
		mannequin.avatar_data = {"topType": 1, "hairType": 1, "bottomType": 1, "baseType": 1}
	# else:
	# 	AvatarData avatarData = PlayerController.instance.avatarData;
	# 	mannequin.avatarData = new AvatarData(avatarData.key, avatarData.name, avatarData.type, Vector3.Zero, avatarData.hairType, avatarData.topType, avatarData.bottomType, avatarData.baseType);

	mannequin.set_idle()
	draw_labels()


func draw_labels():
	var data

	if is_creating:
		data = mannequin.avatar_data
	# else
	#   data = PlayerController.instance.avatarData;

	hair_label.text = "Haircut %s" % data.hairType
	top_label.text = "Top %s" % data.topType
	bottom_label.text = "Bottom %s" % data.bottomType


func set_base_type(new_base_type: int):
	mannequin.avatar_data.baseType = new_base_type


# func save_avatar():
#       ProfileData profile = new ProfileData(SessionManager.GetUserId());

#       await profile.Load();

#       for (int i = 0; i < profile.avatars.Count; i++) {
#         AvatarData a = profile.avatars.list[i];

#         if (a.key == PlayerController.instance.avatarData.key) {
#           a.hairType = mannequin.avatarData.hairType;
#           a.topType = mannequin.avatarData.topType;
#           a.bottomType = mannequin.avatarData.bottomType;
#         }

# #       await profile.Save();

# #       new AvatarUpdateEvent(new AvatarUpdateEventArgs(), SessionManager.GetUserId());
# #     }


func shift_outfit_piece(key: String, shift_up: bool):
	if key == "hair":
		mannequin.avatar_data.hairType = shift_outfit_int(mannequin.avatar_data.hairType, shift_up)
		hair_label.text = "Haircut %s" % mannequin.avatar_data.hairType
	elif key == "top":
		mannequin.avatar_data.topType = shift_outfit_int(mannequin.avatar_data.topType, shift_up)
		top_label.text = "Top %s" % mannequin.avatar_data.topType
	elif key == "bottom":
		mannequin.avatar_data.bottomType = shift_outfit_int(
			mannequin.avatar_data.bottomType, shift_up
		)
		bottom_label.text = "Bottom %s" % mannequin.avatar_data.bottomType


func shift_outfit_int(current_int: int, shift_up: bool) -> int:
	current_int += 1 if shift_up else -1

	if current_int > OUTFIT_LIMIT:
		current_int = 1
	elif current_int < 1:
		current_int = OUTFIT_LIMIT

	return current_int
