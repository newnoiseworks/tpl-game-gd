extends AcceptDialog

signal confirm_callback


func _ready():
	var _c = TPLG.connect("ui_message_dialog", self, "show_message")


func message_dialog_confirmed():
	emit_signal("confirm_callback")


func show_message(message: String):
	# message = Regex.Replace(message, "(.{" + 48 + "})", "$1" + System.Environment.NewLine); ???????
	if message == null:
		message = "Something went wrong, please try again."

	dialog_text = message
	popup_centered()
