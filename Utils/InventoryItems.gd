extends Node

const plant_growth_stages = {
	"1ae4f24c55b5f623f1096fbc5081d236":
	[
		1,
		1,
		1,
		1,
		1,
	],
	"d846ed6b27749f802150466e9ed6f303":
	[
		1,
		1,
		1,
		1,
		1,
	],
	"39b5c3cb61c0271dc445971f94da7f48":
	[
		1,
		1,
		1,
		1,
		1,
		1,
	],
	"b2585bc3e070132d2bf51dffae794f64":
	[
		1,
		1,
		1,
		1,
		1,
		1,
	],
	"bb8e09a312941709ab85b7b147c74abc":
	[
		1,
		1,
		1,
		1,
		1,
		1,
	],
	"aece6208ee77d49f49d29099eb231fac":
	[
		1,
		1,
		1,
		1,
		1,
		1,
	],
	"77bd79b3dca1f49815655b6f2df760ba":
	[
		1,
		1,
		1,
		1,
		1,
	],
	"043a46a48c1f62dd647c5b570c01fb4c":
	[
		1,
		1,
		1,
		1,
		1,
	],
}

const hash_to_id_map = {
	"e5ff605ce91bbc77b6460929fbf46562": 0,
	"062165e71238995898da9559eeb0dddf": 1,
	"160fe77b37f21af0891f50091de9adb4": 2,
	"ba29015816109e1654fa7dedd0ef5e08": 3,
	"ed4dd6cc118ab2500715cbd23b054573": 4,
	"5bc79158d92a8220990dfe9b2c932e28": 5,
	"6d4184af89780f6e5482d49937f403ae": 6,
	"2ff4ab1d379832d3edee28194fb4e7b2": 7,
	"a7de5905fd9b099fe12ff4542516bcae": 8,
	"6e4dd7ce4ea3c1d4a90edb289e22da98": 9,
	"718b927d53673d48e7c6cc7ab24d4609": 10,
	"c52947bacadae6f315d39e0c405f42f9": 11,
	"4b2ced071b104372a477eaccd1d2c3b4": 12,
	"01afa994105d7f76fef3d224767644c2": 13,
	"2f4959e21111337b4c6e42bf2c2a81af": 14,
	"ad81ccaeb50deb745b1f005a88fe6d23": 15,
	"33a961e90507a15d8429850e27d3544b": 16,
	"1ae4f24c55b5f623f1096fbc5081d236": 17,
	"5a16f3ce4ecc0622fe0fa09236265957": 18,
	"d846ed6b27749f802150466e9ed6f303": 19,
	"29201c7b69296186b7baf85825799366": 20,
	"39b5c3cb61c0271dc445971f94da7f48": 21,
	"a0175b7441dcef49e698039c106dce92": 22,
	"b2585bc3e070132d2bf51dffae794f64": 23,
	"6c137d3c4e02bb3dbfd084a87ac2afb0": 24,
	"bb8e09a312941709ab85b7b147c74abc": 25,
	"dca148e0ba17645ea48cd7e199a66f2b": 26,
	"aece6208ee77d49f49d29099eb231fac": 27,
	"024a5b04d8df9b2aabfd7c5ad1927e48": 28,
	"77bd79b3dca1f49815655b6f2df760ba": 29,
	"41ba234765c7a796b62f25163ad047eb": 30,
	"043a46a48c1f62dd647c5b570c01fb4c": 31,
}

const id_to_hash_map = {
	0: "e5ff605ce91bbc77b6460929fbf46562",
	1: "062165e71238995898da9559eeb0dddf",
	2: "160fe77b37f21af0891f50091de9adb4",
	3: "ba29015816109e1654fa7dedd0ef5e08",
	4: "ed4dd6cc118ab2500715cbd23b054573",
	5: "5bc79158d92a8220990dfe9b2c932e28",
	6: "6d4184af89780f6e5482d49937f403ae",
	7: "2ff4ab1d379832d3edee28194fb4e7b2",
	8: "a7de5905fd9b099fe12ff4542516bcae",
	9: "6e4dd7ce4ea3c1d4a90edb289e22da98",
	10: "718b927d53673d48e7c6cc7ab24d4609",
	11: "c52947bacadae6f315d39e0c405f42f9",
	12: "4b2ced071b104372a477eaccd1d2c3b4",
	13: "01afa994105d7f76fef3d224767644c2",
	14: "2f4959e21111337b4c6e42bf2c2a81af",
	15: "ad81ccaeb50deb745b1f005a88fe6d23",
	16: "33a961e90507a15d8429850e27d3544b",
	17: "1ae4f24c55b5f623f1096fbc5081d236",
	18: "5a16f3ce4ecc0622fe0fa09236265957",
	19: "d846ed6b27749f802150466e9ed6f303",
	20: "29201c7b69296186b7baf85825799366",
	21: "39b5c3cb61c0271dc445971f94da7f48",
	22: "a0175b7441dcef49e698039c106dce92",
	23: "b2585bc3e070132d2bf51dffae794f64",
	24: "6c137d3c4e02bb3dbfd084a87ac2afb0",
	25: "bb8e09a312941709ab85b7b147c74abc",
	26: "dca148e0ba17645ea48cd7e199a66f2b",
	27: "aece6208ee77d49f49d29099eb231fac",
	28: "024a5b04d8df9b2aabfd7c5ad1927e48",
	29: "77bd79b3dca1f49815655b6f2df760ba",
	30: "41ba234765c7a796b62f25163ad047eb",
	31: "043a46a48c1f62dd647c5b570c01fb4c",
}

enum {
	TILLER = 0,
	PAIL = 1,
	PICKAXE = 2,
	SCYTHE = 3,
	AXE = 4,
	CORPUS_COIN = 5,
	COMMUNITY_COIN = 6,
	STONE = 7,
	FERN = 8,
	WOOD = 9,
	BLUEPRINT__STONE_PATH = 10,
	BLUEPRINT__WOOD_PATH = 11,
	BLUEPRINT__LAMP = 12,
	CRAFTED__STONE_PATH = 13,
	CRAFTED__WOOD_PATH = 14,
	CRAFTED__LAMP = 15,
	BEET_SEEDS = 16,
	BEET = 17,
	CABBAGE_SEEDS = 18,
	CABBAGE = 19,
	DRAGON_FRUIT_SEEDS = 20,
	DRAGON_FRUIT = 21,
	EGGPLANT_SEEDS = 22,
	EGGPLANT = 23,
	POTATO_SEEDS = 24,
	POTATO = 25,
	ODD_FRUIT_SEEDS = 26,
	ODD_FRUIT = 27,
	TOMATO_SEEDS = 28,
	TOMATO = 29,
	TURNIP_SEEDS = 30,
	TURNIP = 31,
}

const name_to_enum_map = {
	"Tiller": 0,
	"Pail": 1,
	"Pickaxe": 2,
	"Scythe": 3,
	"Axe": 4,
	"CorpusCoin": 5,
	"CommunityCoin": 6,
	"Stone": 7,
	"Fern": 8,
	"Wood": 9,
	"Blueprint_StonePath": 10,
	"Blueprint_WoodPath": 11,
	"Blueprint_Lamp": 12,
	"Crafted_StonePath": 13,
	"Crafted_WoodPath": 14,
	"Crafted_Lamp": 15,
	"BeetSeeds": 16,
	"Beet": 17,
	"CabbageSeeds": 18,
	"Cabbage": 19,
	"DragonFruitSeeds": 20,
	"DragonFruit": 21,
	"EggplantSeeds": 22,
	"Eggplant": 23,
	"PotatoSeeds": 24,
	"Potato": 25,
	"OddFruitSeeds": 26,
	"OddFruit": 27,
	"TomatoSeeds": 28,
	"Tomato": 29,
	"TurnipSeeds": 30,
	"Turnip": 31,
}


func get_hash_from_int(id: int):
	return id_to_hash_map[id]


func get_int_from_hash(id: String):
	return hash_to_id_map[id]


func get_int_from_name(id: String):
	return name_to_enum_map[id]

#		public static InventoryItemType GetEnum(string id) {
#			return (InventoryItemType)GetIntFromHash(id);
#		}
#
#		public static InventoryItemType GetEnum(int id) {
#			return (InventoryItemType)id;
#		}
#
#		public static string GetHash(InventoryItemType type) {
#			return GetHashFromInt((int)type);
#		}
#	}
#
#}
