extends HBoxContainer

export var title: String

onready var label: Label = $Label


func _ready():
	label.text = title
