extends "res://Scenes/Items/ItemController.gd"


func _ready():
	TPLG.dialogue.add_dialogue_script("computer_haus_store", self)


func _exit_tree():
	TPLG.dialogue.remove_dialogue_script("computer_haus_store")


func interact():
	TPLG.dialogue.start("ComputerHaus", "hello")


func computer_haus_store():
	TPLG.store.populate_store(
		[
			InventoryItems.CABBAGE_SEEDS,
			InventoryItems.BEET_SEEDS,
			InventoryItems.DRAGON_FRUIT_SEEDS,
			InventoryItems.EGGPLANT_SEEDS,
			InventoryItems.TOMATO_SEEDS,
			InventoryItems.TURNIP_SEEDS,
			InventoryItems.POTATO_SEEDS,
			InventoryItems.TURNIP_SEEDS,
		],
		[
			InventoryItems.CABBAGE,
			InventoryItems.BEET,
			InventoryItems.DRAGON_FRUIT,
			InventoryItems.EGGPLANT,
			InventoryItems.TOMATO,
			InventoryItems.TURNIP,
			InventoryItems.POTATO,
			InventoryItems.TURNIP,
			InventoryItems.FISH
		]
	)
