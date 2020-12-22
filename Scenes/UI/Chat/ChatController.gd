extends VBoxContainer

onready var chat_log: RichTextLabel = $Log
onready var postbox: LineEdit = find_node("Postbox")


func _ready():
	hide_postbox()
	RealmManager.socket.connect("received_channel_message", self, "_on_channel_message")


func _exit_tree():
	RealmManager.socket.disconnect("received_channel_message", self, "_on_channel_message")


func _on_channel_message(msg: NakamaAPI.ApiChannelMessage):
	if (
		msg.channel_id == RealmManager.chat_channel.id
		&& msg.sender_id != SessionManager.session.user_id
	):
		_post_message(JSON.parse(msg.content).result.message)


func show_postbox():
	postbox.show()
	postbox.grab_focus()


func hide_postbox():
	postbox.hide()


func post_text():
	if postbox.text != null && postbox.text != "" && postbox.text.length() > 0:
		var msg = _format_message(postbox.text)
		_post_message(msg)
		_post_message_online(msg)
		postbox.clear()


func _format_message(message: String) -> String:
	return "[u]%s[/u]: %s" % [SessionManager.current_avatar.name, message]


func _post_message(message: String):
	chat_log.bbcode_text += "\r\n" + message
	chat_log.scroll_to_line(chat_log.get_line_count() - 1)


func _post_message_online(message: String):
	var channel_id = RealmManager.chat_channel.id

	var message_ack: NakamaRTAPI.ChannelMessageAck = yield(
		RealmManager.socket.write_chat_message_async(channel_id, {"message": message}), "completed"
	)

	if message_ack.is_exception():
		print("An error occured sending a message: %s" % message_ack)
