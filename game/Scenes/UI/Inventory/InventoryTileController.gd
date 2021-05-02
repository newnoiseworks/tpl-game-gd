extends TextureButton

signal select_slot
signal equip_item

var point_tween_values_inverted = false
var stop_pointing_called = false

onready var quantity_count_label: Label = $QuantityCount
onready var title_label: Label = $Title
onready var title_tween: Tween = $TitleTween
onready var pointer_tween: Tween = $PointerTween
onready var arrow: Sprite = $Arrow
onready var point_tween_values: Array = [arrow.position, arrow.position + Vector2(0, 9)]


func point_at_tile():
	if stop_pointing_called:
		return

	arrow.show()

	pointer_tween.interpolate_property(
		arrow,
		"position",
		point_tween_values[0],
		point_tween_values[1],
		.66,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	pointer_tween.connect("tween_completed", self, "_on_tween_completed")

	pointer_tween.start()


func _on_tween_completed(_a, _b):
	pointer_tween.disconnect("tween_completed", self, "_on_tween_completed")
	point_tween_values.invert()
	point_tween_values_inverted = ! point_tween_values_inverted


func stop_pointing():
	stop_pointing_called = true
	pointer_tween.stop_all()

	stop_pointing_called = false

	arrow.hide()

	if point_tween_values_inverted:
		point_tween_values.invert()
		point_tween_values_inverted = false

	arrow.position = point_tween_values[0]


func flash_title():
	for tile in TPLG.inventory.tiles:
		tile.hide_title()

	title_tween.interpolate_property(
		title_label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	title_tween.interpolate_property(
		title_label,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		2
	)

	title_tween.start()


func hide_title():
	if title_label.modulate == Color(1, 1, 1, 0):
		return

	title_tween.stop(title_label, "modulate")

	title_tween.interpolate_property(
		title_label,
		"modulate",
		title_label.modulate,
		Color(1, 1, 1, 0),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	title_tween.start()


func update_quantity(count: int, always_show: bool = false):
	if always_show == false && count <= 1:
		quantity_count_label.hide()
		return

	quantity_count_label.text = String(count)
	quantity_count_label.show()


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			BUTTON_LEFT:
				emit_signal("equip_item")
			BUTTON_RIGHT:
				emit_signal("select_slot")
