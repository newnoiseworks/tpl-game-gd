extends CanvasLayer

onready var saving_label: Label = get_node("Container/TopLeft/SavingLabel")
onready var toast_label: Label = find_node("ToastLabel")
onready var loading_dialog: WindowDialog = get_node("Modals/LoadingDialog")
onready var tween: Tween = find_node("Tween")
onready var timer: Timer = Timer.new()
onready var instructions: TextureRect = find_node("Instructions")
onready var mission_list = find_node("MissionList")
onready var chat = find_node("Chat")
onready var new_mission_popup = find_node("NewMissionPopup")


func _ready():
	TPLG.set_ui(self)
	timer.wait_time = 5
	timer.one_shot = true
	timer.connect("timeout", self, "hide_label")
	add_child(timer)


func _exit_tree():
	TPLG.ui = null


func toggle_instructions():
	if instructions.visible:
		instructions.hide()
	else:
		instructions.show()


func show_saving_indicator():
	saving_label.show()


func hide_saving_indicator():
	saving_label.hide()


func show_loading_dialog():
	loading_dialog.show()


func hide_loading_dialog():
	loading_dialog.hide()


func show_toast(message: String):
	print("show toast message: %s" % message)
	toast_label.text = message

	_show_toast()


func _show_toast():
	tween.interpolate_property(
		toast_label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.start()
	timer.start()


func hide_label():
	tween.interpolate_property(
		toast_label,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		2.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.start()
