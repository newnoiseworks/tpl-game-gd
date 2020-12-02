extends "res://Scenes/Items/ItemController.gd"

onready var character = get_parent()  # : CharacterController.gd


func interact():
	character.interact()
