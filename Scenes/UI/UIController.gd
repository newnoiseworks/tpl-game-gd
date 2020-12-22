extends CanvasLayer

onready var saving_label: Label = get_node("Container/TopLeft/SavingLabel")
onready var toast_label: Label = find_node("AlertLabel")
onready var loading_dialog: WindowDialog = get_node("Modals/LoadingDialog")
onready var tween: Tween = find_node("Tween")
onready var timer: Timer = Timer.new()
onready var instructions: TextureRect = find_node("Instructions")
onready var mission_list = find_node("MissionList")
onready var chat = find_node("Chat")


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
	toast_label.show()
	var starting_point = toast_label.rect_position + Vector2(800, 0)
	var original_position = toast_label.rect_position
	toast_label.rect_position = starting_point

	tween.interpolate_property(
		toast_label,
		"rect_position",
		starting_point,
		original_position,
		1.5,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)

	tween.start()
	timer.start()


func hide_label():
	toast_label.hide()
