extends "res://Scenes/Character/CharacterController.gd"


func _ready():
	TPLG.dialogue.add_dialogue_script("violine_store", self)


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("violine_store")


func violine_store():
	var blueprints = [
		InventoryItems.BLUEPRINT__WOOD_PATH,
		InventoryItems.BLUEPRINT__STONE_PATH,
		InventoryItems.BLUEPRINT__LAMP,
		InventoryItems.BLUEPRINT__LAMP2,
		InventoryItems.BLUEPRINT__LAMP3,
		InventoryItems.BLUEPRINT__LAMP4,
		InventoryItems.BLUEPRINT__LAMP5,
	]

	var final_blueprints = []

	for blueprint in blueprints:
		if ! TPLG.reatomizer.has_blueprint(blueprint):
			final_blueprints.append(blueprint)

	TPLG.store.populate_store(
		final_blueprints,
		[
			InventoryItems.WOOD,
			InventoryItems.STONE,
			InventoryItems.FERN,
		]
	)
