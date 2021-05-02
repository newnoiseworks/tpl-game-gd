local nk = require("nakama")
local items = require("inventory_items")

local I = {
  stone = {
    variant_count = 3,
    damage_on_hit = 10,
    generation_chance = 20,
    health = 10,
    drop_items = {
      {
        type = items.reverse["Stone"],
        min = 2,
        max = 5,
        drop_chance = 100
      }
    }
  },
  weed = {
    variant_count = 4,
    damage_on_hit = 10,
    generation_chance = 50,
    health = 10,
    drop_items = {
      {
        type = items.reverse["Fern"],
        min = 1,
        max = 1,
        drop_chance = 33
      }
    }
  },
  tallGrass = {
    variant_count = 1,
    damage_on_hit = 10,
    generation_chance = 100,
    health = 10,
    drop_items = {}
  },
  tree = {
    variant_count = 5,
    damage_on_hit = 10,
    generation_chance = 30,
    health = 50,
    drop_items = {
      {
        type = items.reverse["Wood"],
        min = 5,
        max = 10,
        drop_chance = 100
      }
    }
  }
}

I.enum_index = {}
I.enum_index[0] = I.stone
I.enum_index[1] = I.weed
I.enum_index[2] = I.tree
I.enum_index[3] = I.tallGrass

return I
