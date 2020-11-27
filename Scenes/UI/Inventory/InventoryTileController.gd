extends TextureButton

signal select_slot
signal equip_item

onready var quantity_count_label: Label = find_node("QuantityCount")


func update_quantity(count: int, always_show: bool = false):
	if always_show == false && count <= 1:
		quantity_count_label.Hide()

	quantity_count_label.text = String(count)
	quantity_count_label.show()


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton && event.Pressed:
		match event.button_index:
			BUTTON_LEFT:
				emit_signal("equip_item")
			BUTTON_RIGHT:
				emit_signal("select_slot")
