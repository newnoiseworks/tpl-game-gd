extends HBoxContainer

var title: String
var key: String
var finished: bool = false

onready var label: Label = $Label


func _ready():
	label.text = title


func mark_as_finished():
	hide()
	queue_free()
