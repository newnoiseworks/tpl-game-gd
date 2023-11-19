local mission_list = {
	createAvatar = {
    title = "Create an avatar",
  },
	tutorialFarmingTilling = {
    title = "Learn how to till soil",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 50
			},
		}
  },
	tutorialFarmingPlanting = {
    title = "Learn how to plant seeds",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 50
			},
		}
  },
	tutorialFarmingWatering = {
    title = "Learn how to water plants",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 50
			},
		}
  },
	tutorialFarmingHarvesting = {
    title = "Learn how to harvest plants",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 50
			},
		}
  },
	tutorialForaging = {
    title = "Learn how to forage",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 15
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 150
			},
		}
  },
	introJKJZ = {
    title = "Talk to the floating robot on the road",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	visitTown = {
    title = "Visit town by walking down the road",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	sayHiToSakana = {
    title = "Say hello to Sakana",
		prereqs = "introJKJZ",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	sayHiToBaph = {
    title = "Say hello to Baph",
		prereqs = "introJKJZ",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	learnEconFromJKJZ = {
    title = "Learn economics from JKJZ",
		prereqs = "introJKJZ",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	meetComputerHaus = {
    title = "Meet ComputerHaus",
		prereqs = "learnEconFromJKJZ",
		awards = {
			{
				key = "5bc79158d92a8220990dfe9b2c932e28",
				quantity = 5
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	catchGilAFish = {
    title = "Catch a fish for Gil",
		prereqs = "introJKJZ",
		reqs = {
			{
				key = "071642fa72ba780ee90ed36350d82745",
				quantity = 1
			},
		},
		awards = {
			{
				key = "6d4184af89780f6e5482d49937f403ae",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	farmGilPotatoes = {
    title = "Get Gil 10 potatoes",
		prereqs = "catchGilAFish",
		reqs = {
			{
				key = "bb8e09a312941709ab85b7b147c74abc",
				quantity = 10
			},
		},
		awards = {
			{
				key = "6d4184af89780f6e5482d49937f403ae",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	forageForVio = {
    title = "Forage 10 pieces of stone for Violine",
		prereqs = "introJKJZ",
		reqs = {
			{
				key = "2ff4ab1d379832d3edee28194fb4e7b2",
				quantity = 10
			},
		},
		awards = {
			{
				key = "6d4184af89780f6e5482d49937f403ae",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	tomatoesForSakana = {
    title = "Sakana needs one tomato",
		prereqs = "introJKJZ,sayHiToSakana",
		reqs = {
			{
				key = "77bd79b3dca1f49815655b6f2df760ba",
				quantity = 1
			},
		},
		awards = {
			{
				key = "6d4184af89780f6e5482d49937f403ae",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
	pickupYorksHearts = {
    title = "Pickup the five hearts York dropped in town",
		reqs = {
			{
				key = "7831b88a54a8f20734b6801ca84433db",
				quantity = 5
			},
		},
		awards = {
			{
				key = "6d4184af89780f6e5482d49937f403ae",
				quantity = 10
			},
			{
				key = "140c2262da22bff433c87b354bf4d822",
				quantity = 100
			},
		}
  },
}

return mission_list
