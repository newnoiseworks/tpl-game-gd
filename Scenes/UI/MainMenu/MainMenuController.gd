extends Popup

onready var tabs: TabContainer = find_node("TabContainer")


func popup_centered(_size = Vector2(0, 0)):
	for child in tabs.get_children():
		child.ready_on_popup()

	.popup_centered()


func on_tab_container_tab_selected(tab: int):
	if tabs != null:
		tabs.get_children()[tab].ready_on_popup()
