extends "res://Scenes/Character/CharacterController.gd"


func _ready():
	TPLG.dialogue.add_dialogue_script("violine_store", self)


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("violine_store")


func violine_store():
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
