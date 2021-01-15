extends TextureButton

signal select_slot
signal equip_item

onready var quantity_count_label: Label = $QuantityCount
onready var title_label: Label = $Title
onready var tween: Tween = $Tween


func flash_title():
	for tile in TPLG.inventory.tiles:
		tile.hide_title()

	tween.interpolate_property(
		title_label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.interpolate_property(
		title_label,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		2
	)

	tween.start()


func hide_title():
	if title_label.modulate == Color(1, 1, 1, 0):
		return

	tween.stop(title_label, "modulate")

	tween.interpolate_property(
		title_label,
		"modulate",
		title_label.modulate,
		Color(1, 1, 1, 0),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.start()


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
