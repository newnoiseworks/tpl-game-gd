extends Node2D

onready var label: Label = $Label
onready var tween: Tween = $Tween
onready var original_scale: Vector2 = label.get_scale()
onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func appear():
	show()

	tween.interpolate_property(
		label,
		"rect_scale",
		original_scale,
		original_scale * 4,
		1.25,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)

	audio.play()

	tween.start()


func reset():
	label.rect_scale = original_scale
	hide()
