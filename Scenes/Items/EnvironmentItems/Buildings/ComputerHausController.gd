extends "res://Scenes/Items/ItemController.gd"

signal computer_haus_store


func _ready():
	pass


func _exit_tree():
	# TPLG.dialogue.remove_dialogue_script("computer_haus_store")
	# disconnect("computer_haus_store", self, "start_store")
	pass


func interact():
	TPLG.dialogue.add_dialogue_script("computer_haus_store", self)
	connect("computer_haus_store", self, "start_store")
	TPLG.dialogue.start("ComputerHaus", "hello")


func start_store():
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
		]
	)
