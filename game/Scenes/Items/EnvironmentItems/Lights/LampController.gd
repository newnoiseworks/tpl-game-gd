extends "res://Scenes/Items/CraftedItemController.gd"

onready var light: Light2D = find_node("Light2D")


func _ready():
	if GameTime.is_day():
		turn_lamp_off()
	else:
		turn_lamp_on()

	GameTime.connect("daybreak_event", self, "turn_lamp_off")
	GameTime.connect("nightfall_event", self, "turn_lamp_on")


func _exit_tree():
	if GameTime.is_connected("daybreak_event", self, "turn_lamp_off"):
		GameTime.disconnect("daybreak_event", self, "turn_lamp_off")

	if GameTime.is_connected("nightfall_event", self, "turn_lamp_on"):
		GameTime.disconnect("nightfall_event", self, "turn_lamp_on")


func turn_lamp_off():
	light.enabled = false


func turn_lamp_on():
	light.enabled = true


func ready_for_inventory():
	find_node("TileMap").hide()
	find_node("Inventory").show()

	GameTime.disconnect("daybreak_event", self, "turn_lamp_off")
	GameTime.disconnect("nightfall_event", self, "turn_lamp_on")

	turn_lamp_off()
