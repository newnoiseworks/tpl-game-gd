local nk = require("nakama")
local items = require("inventory_items")
local fi = require("forage_items")

local function determine_drop_items(forage_item)
  local dropItems = {}

  for _, i in ipairs(forage_item.drop_items) do
    local count = 0

    if (math.random(0, 100) <= i.drop_chance) then
      count = math.floor(math.random(i.min, i.max))
    end

    if (count > 0) then
      table.insert(
        dropItems,
        {
          type = i.type,
          count = count
        }
      )
    end
  end

  return dropItems
end

function generate_farms(context, payload)
  for xGrid = 1, 4, 1 do
    for yGrid = 1, 4, 1 do
      local forageItems = {}
      local forageItemsMaxTypeEnum = 3
      local forageItemsIndex = {}

      for x = 0, 15, 1 do
        forageItemsIndex[x] = {}

        for y = 0, 15, 1 do
          local type = math.random(0, forageItemsMaxTypeEnum)
          local item = fi.enum_index[type]

          local canTree = true

          -- 2 should be a tree
          if (type == 2) then
            local possibleTreeX = nil

            if forageItemsIndex[x - 1] ~= nil then
              possibleTreeX = forageItemsIndex[x - 1][y]
            end

            local possibleTreeY = forageItemsIndex[x][y - 1]

            if (possibleTreeX ~= nil or possibleTreeY ~= nil) then
              canTree = false
            end
          end

          if canTree and math.random(0, 100) < item.generation_chance then
            local variant = math.random(0, item.variant_count - 1)
            local flippedX = math.random(0, 100) < 49

            local dropItems = determine_drop_items(item)

            local dropItemData = {
              x = x,
              y = y,
              type = type,
              variant = variant,
              flippedX = flippedX,
              health = item.health,
              damageOnHit = item.damage_on_hit,
              dropItems = dropItems
            }

            forageItemsIndex[x][y] = dropItemData

            table.insert(forageItems, dropItemData)
          end
        end
      end

      nk.storage_write(
        {
          {
            collection = "farmGrid-" .. xGrid .. "-" .. yGrid,
            key = payload,
            user_id = context.user_id,
            value = {
              forageItems = forageItems,
              craftedItems = {}
            },
            permission_read = 2,
            permission_write = 0
          }
        }
      )
    end
  end

  nk.storage_write(
    {
      {
        collection = "town0CommunityFarmGrid",
        key = payload,
        user_id = context.user_id,
        value = {
          forageItems = {},
          craftedItems = {}
        },
        permission_read = 2,
        permission_write = 0
      }
    }
  )
end

local function register_new_user(context, payload)
  local missionData = {
    missions = {
      {
        key = "createAvatar",
        finished = 1
      },
      {
        key = "introJKJZ",
        finished = 0
      },
    }
  }

  nk.storage_write(
    {
      {
        collection = "missionData",
        key = payload,
        user_id = context.user_id,
        value = missionData,
        permission_read = 2,
        permission_write = 0
      }
    }
  )

  local reatomizer = {
    blueprints = {}
  }

  nk.storage_write(
    {
      {
        collection = "reatomizer",
        key = payload,
        user_id = context.user_id,
        value = reatomizer,
        permission_read = 2,
        permission_write = 0
      }
    }
  )

  local inventory = {}

  inventory.bag = {
    {
      itemTypeId = items.reverse["Tiller"],
      bagPosition = 0,
      quantity = 1
    },
    {
      itemTypeId = items.reverse["Pail"],
      bagPosition = 1,
      quantity = 1
    },
    {
      itemTypeId = items.reverse["Pickaxe"],
      bagPosition = 2,
      quantity = 1
    },
    {
      itemTypeId = items.reverse["Scythe"],
      bagPosition = 3,
      quantity = 1
    },
    {
      itemTypeId = items.reverse["Axe"],
      bagPosition = 4,
      quantity = 1
    },
    {
      itemTypeId = items.reverse["Fishpole"],
      bagPosition = 5,
      quantity = 1
    }
  }

  nk.storage_write(
    {
      {
        collection = "inventoryBag",
        key = payload,
        user_id = context.user_id,
        value = inventory,
        permission_read = 2,
        permission_write = 0
      }
    }
  )

  generate_farms(context, payload)

  local changeset = {
    ["CorpusCoin-" .. payload] = 10,
    ["CommunityCoin-" .. payload] = 25,
    ["ExperienceCoin-" .. payload] = 0
  }
  local metadata = {
    game_result = "initial-wallet-via-avatar-creation"
  }
  nk.wallet_update(context.user_id, changeset, metadata, true)
end

nk.register_rpc(register_new_user, "user.on_registration")
