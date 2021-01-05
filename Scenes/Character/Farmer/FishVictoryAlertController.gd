extends Node2D

onready var label: Label = $Label
onready var tween: Tween = $Tween
onready var original_scale: Vector2 = label.get_scale()


func _ready():
	tween.connect("tween_all_completed", self, "reset")


func appear(weight):
	label.text = "%s lbs!" % weight

	show()

	tween.interpolate_property(
		label, "rect_scale", original_scale, original_scale * 4, 5, Tween.TRANS_QUAD, Tween.EASE_OUT
	)

	tween.start()


func reset():
	label.rect_scale = original_scale
	hide()
