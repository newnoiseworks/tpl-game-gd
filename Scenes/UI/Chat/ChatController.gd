extends VBoxContainer

onready var chat_log: RichTextLabel = $Log
onready var postbox: LineEdit = find_node("Postbox")


func _ready():
	hide_postbox()


func show_postbox():
	postbox.show()
	postbox.grab_focus()


func hide_postbox():
	postbox.hide()


func post_text():
	if postbox.text != null && postbox.text != "" && postbox.text.length() > 0:
		chat_log.bbcode_text += "\r\n" + postbox.text
		postbox.clear()
