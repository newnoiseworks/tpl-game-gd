extends HBoxContainer

var title: String
var finished: bool = false

onready var label: Label = $Label


func _ready():
	label.text = title
