extends Popup

onready var tabs: TabContainer = find_node("TabContainer")


func popup_centered(_size = Vector2(0, 0)):
	for child in tabs.get_children():
		if child.has_method("ready_on_popup"):
			child.ready_on_popup()

	.popup_centered()


func on_tab_container_tab_selected(tab: int):
	if tabs != null:
		if tabs.get_children()[tab].has_method("ready_on_popup"):
			tabs.get_children()[tab].ready_on_popup()
