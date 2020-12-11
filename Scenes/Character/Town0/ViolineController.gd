extends "res://Scenes/Character/CharacterController.gd"

signal violine_store


func _ready():
	TPLG.dialogue.add_dialogue_script("violine_store", self)
	connect("violine_store", self, "start_store")


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("violine_store")
	disconnect("violine_store", self, "start_store")


func start_store():
	TPLG.store.populate_store(
		[
			InventoryItems.BLUEPRINT__WOOD_PATH,
			InventoryItems.BLUEPRINT__STONE_PATH,
			InventoryItems.BLUEPRINT__LAMP,
		],
		[
			InventoryItems.WOOD,
			InventoryItems.STONE,
			InventoryItems.FERN,
		]
	)
