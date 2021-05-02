extends HBoxContainer

signal permission_toggled(permission_type, on)

var toggle_on: bool

var label_text: String

onready var label: RichTextLabel = find_node("RichTextLabel")
onready var check: CheckButton = find_node("CheckButton")


func _ready():
	label.text = label_text
	check.pressed = toggle_on


func on_toggle(toggled: bool):
	if toggle_on == toggled:
		return

	emit_signal("permission_toggled", label_text, toggled)
