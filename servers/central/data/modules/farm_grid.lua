local nk = require("nakama")
local items = require("inventory_items")
local inventory = require("inventory")
local validator = require("item_validation")
local time = require("time")

local M = {}

local tilled_tile_name = "tilled"

function M.handle_match_farm_action(message)
  log_method_call("farm_grid.M.handle_match_farm_context", message.sender, message.data)
  local data = nk.json_decode(message.data)

  if
    (M.has_farm_permissions(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.type
    ) == false)
   then
    return false
  end

  if data.type == 0 then -- validate plant action
    return M.plant(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  elseif data.type == 1 then -- validate till action
    return M.till(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y
    )
  elseif data.type == 2 then -- validate harvest action
    return M.harvest(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  elseif data.type == 3 then -- validate forage action
    return M.forage(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  elseif data.type == 4 then -- validate place crafted item action
    return M.place_crafted_item(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  elseif data.type == 5 then -- validate remove crafted item action
    return M.remove_crafted_item(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  elseif data.type == 6 then -- validate detill action
    return M.detill(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y
    )
  elseif data.type == 7 then -- validate water action
    return M.water_plant(
      message.sender.user_id,
      data.avatar,
      data.farm_owner_id,
      data.farm_owner_avatar,
      data.farm_collection,
      data.x,
      data.y,
      data.metadata
    )
  end

  return false
end

local permMap = {
  [0] = "plant",
  [1] = "till",
  [2] = "harvest",
  [3] = "forage",
  [6] = "till"
}

local permCollectionMap = {
  ["farmGrid-1-1"] = "town0FarmGridPermissions",
  ["farmGrid-2-1"] = "town0FarmGridPermissions",
  ["farmGrid-3-1"] = "town0FarmGridPermissions",
  ["farmGrid-4-1"] = "town0FarmGridPermissions",
  ["farmGrid-1-2"] = "town0FarmGridPermissions",
  ["farmGrid-2-2"] = "town0FarmGridPermissions",
  ["farmGrid-3-2"] = "town0FarmGridPermissions",
  ["farmGrid-4-2"] = "town0FarmGridPermissions",
  ["farmGrid-1-3"] = "town0FarmGridPermissions",
  ["farmGrid-2-3"] = "town0FarmGridPermissions",
  ["farmGrid-3-3"] = "town0FarmGridPermissions",
  ["farmGrid-4-3"] = "town0FarmGridPermissions",
  ["farmGrid-1-4"] = "town0FarmGridPermissions",
  ["farmGrid-2-4"] = "town0FarmGridPermissions",
  ["farmGrid-3-4"] = "town0FarmGridPermissions",
  ["farmGrid-4-4"] = "town0FarmGridPermissions",
  ["town0CommunityFarmGrid"] = "town0CommunityFarmPermissions"
}

function M.has_farm_permissions(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, type)
  if (user_id == farm_owner_id) then
    return true
  end

  local perms =
    nk.storage_read(
    {
      {
        collection = permCollectionMap[farm_collection],
        key = farm_owner_avatar,
        user_id = farm_owner_id
      }
    }
  )

  if (perms[1] == nil or perms[1].value == nil) then
    return false
  end

  perms = perms[1].value

  if (perms.permCollection ~= nil and perms.permCollection[user_id] ~= nil) then
    return perms.permCollection[user_id][permMap[type]] == 1
  end

  if (perms.defaultPermissions ~= nil) then
    return perms.defaultPermissions[permMap[type]] == 1
  end

  return false
end

function M.place_crafted_item(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)

  for _, i in ipairs(farm.craftedItems) do
    if (tostring(x) == tostring(i.x) and tostring(y) == tostring(i.y)) then
      return false
    end
  end

  for _, i in ipairs(farm.forageItems) do
    if (tostring(x) == tostring(i.x) and tostring(y) == tostring(i.y) and i.health > 0) then
      return false
    end
  end

  if (farm.plants ~= nil) then
    for _, i in ipairs(farm.plants) do
      if (tostring(x) == tostring(i.x) and tostring(y) == tostring(i.y)) then
        return false
      end
    end
  end

  if (inventory.has_item(user_id, avatar, type, 1) == false) then
    return false
  end

  inventory.remove_item(user_id, avatar, type, 1)

  table.insert(
    farm.craftedItems,
    {
      x = x,
      y = y,
      type = type
    }
  )

  save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)

  return true
end

function M.remove_crafted_item(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local item = false

  for _, i in ipairs(farm.craftedItems) do
    if (tostring(x) == tostring(i.x) and tostring(y) == tostring(i.y) and type == i.type) then
      item = _
    end
  end

  if (item == false) then
    return false
  end

  table.remove(farm.craftedItems, item)
  save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)
  inventory.add_item(user_id, avatar, type, 1, false)

  return true
end

function M.forage(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local forage_call = forage_action(farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)

  if (forage_call == false) then
    return false
  end

  return true
end

function M.harvest(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local item = items[type]
  local harvest_call = remove_plant(farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)

  if (harvest_call == false) then
    return false
  end

  local maxGrowthStages = 0
  local timesWatered = 0

  for _, g in ipairs(item.growthStages) do
    maxGrowthStages = maxGrowthStages + g
  end

  for _, g in ipairs(harvest_call.waterHistory) do
    timesWatered = timesWatered + g
  end

  local percentWatered = timesWatered / maxGrowthStages
  if percentWatered > 1 then
    percentWatered = 1
  end

  local yield = math.ceil(item.maxYield * percentWatered)
  if yield < 1 then
    yield = 1
  end

  inventory.add_item(user_id, avatar, type, yield, false)
  return true
end

function M.water_plant(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local item = items[type]
  local cropKey = false
  local crop

  for _, p in ipairs(farm.plants) do
    if (tostring(x) == p.x and tostring(y) == p.y and type == p.plantType) then
      cropKey = _
      crop = p
    end
  end

  if (cropKey == false) then
    return false
  end

  local growthStage = 1
  local growthStageCount = 0
  local dayCounter = 0
  local daysSincePlanted = time.number_of_game_days_from_daybreak_unix_timestamp(tonumber(crop.createdAt))

  for _, g in ipairs(item.growthStages) do
    growthStageCount = growthStageCount + 1
  end

  for i = 1, growthStageCount, 1 do
    dayCounter = dayCounter + item.growthStages[i]

    if (daysSincePlanted >= dayCounter) then
      growthStage = i
    else
      break
    end
  end

  if (daysSincePlanted <= growthStageCount) then
    if (crop.waterHistory[growthStage] ~= nil and item.growthStages[growthStage] > crop.waterHistory[growthStage]) then
      crop.waterHistory[growthStage] = crop.waterHistory[growthStage] + 1
    else
      crop.waterHistory[growthStage] = 1
    end
  end

  save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)

  return true
end

function M.till(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y)
  local tile = nil
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)

  local tileRow = farm.groundTiles[tostring(y)]

  if (tileRow ~= nil) then
    tile = tileRow[tostring(x)]
  end

  if (tile == nil) then
    farm.groundTiles[tostring(y)] = farm.groundTiles[tostring(y)] or {}
    farm.groundTiles[tostring(y)][tostring(x)] = tilled_tile_name
    save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)
  elseif (tile) then
    return false
  end

  return true
end

function M.detill(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)

  for _, p in ipairs(farm.plants) do
    if (tostring(x) == p.x and tostring(y) == p.y) then
      return false
    end
  end

  local tileRow = farm.groundTiles[tostring(y)]

  if (tileRow ~= nil and tileRow[tostring(x)] ~= nil and tileRow[tostring(x)] == tilled_tile_name) then
    tileRow[tostring(x)] = nil
    save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)
    return true
  else
    return false
  end
end

function M.plant(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, seed_type)
  local user_inventory = inventory.get_inventory(user_id, avatar)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local plant_type = items.reverse[items[seed_type].to_plant]

  if (can_plant(user_inventory, farm, x, y, seed_type, plant_type) == false) then
    return false
  end

  local water_history = {}

  for _, g in ipairs(items[plant_type].growthStages) do
    water_history[_] = 0
  end

  table.insert(
    farm.plants,
    {
      x = tostring(x),
      y = tostring(y),
      createdAt = string.format("%.f", nk.time() / 1000),
      plantType = plant_type,
      waterHistory = water_history
    }
  )

  inventory.remove_item(user_id, avatar, seed_type, 1)
  save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)

  return true
end

function M.cleanup(user_id, farm_owner_id, farm_owner_avatar, farm_collection)
  if (user_id ~= farm_owner_id) then
    return false
  end

  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local destroyed = false

  for _, f in ipairs(farm.forageItems) do
    if f.destroyed_on ~= nil and f.destroyed_on < nk.time() - 3.6e+6 then
      table.remove(farm.forageItems, _)
      destroyed = true
    end
  end

  if destroyed then
    save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)
  end

  return true
end

function forage_action(farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local item = false
  local itemKey = false

  for _, f in ipairs(farm.forageItems) do
    if (tonumber(x) == f.x and tonumber(y) == f.y and tonumber(type) == f.type) then
      item = f
      itemKey = _
    end
  end

  if (item == false) then
    return false
  end

  if (item.health > 0) then
    item.health = item.health - item.damageOnHit

    if (item.health <= 0) then
      item.destroyed_on = nk.time()
    end

    farm.forageItems[itemKey] = item

    save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)
  end

  return true
end

function remove_plant(farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  local farm = get_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection)
  local crop = false
  local cropKey = false

  -- FUCK: Not checking if plant is harvestable on server side, only client --
  for _, p in ipairs(farm.plants) do
    if (tostring(x) == p.x and tostring(y) == p.y and type == p.plantType) then
      crop = p
      cropKey = _
    end
  end

  if (crop == false) then
    return false
  end

  table.remove(farm.plants, cropKey)
  save_farm_grid(farm_owner_id, farm_owner_avatar, farm_collection, farm)

  return crop
end

function water_plant(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
  return M.water_plant(user_id, avatar, farm_owner_id, farm_owner_avatar, farm_collection, x, y, type)
end

function can_plant(user_inventory, farm, x, y, seed_type, plant_type)
  local tile = nil
  local tile_row = farm.groundTiles[tostring(y)]

  if (tile_row ~= nil) then
    tile = tile_row[tostring(x)]
  end

  if (tile == nil or string.match(tile, "tilled") == false) then
    return false
  end

  for _, p in ipairs(farm.plants) do
    if (p.x == tostring(x) and p.y == tostring(y) and p.plantType == plant_type) then
      return false
    end
  end

  local has_seed = false

  for _, i in ipairs(user_inventory.bag) do
    if (i.itemTypeId == seed_type) then
      has_seed = true
    end
  end

  if (has_seed == false) then
    return false
  end

  return true
end

function get_farm_grid(user_id, avatar, collection)
  local farm =
    nk.storage_read(
    {
      {
        --collection = "farmGrid",
        collection = collection,
        key = avatar,
        user_id = user_id
      }
    }
  )[1].value

  farm.plants = farm.plants or {}
  farm.groundTiles = farm.groundTiles or {}

  return farm
end

function save_farm_grid(user_id, avatar, collection, farm_grid)
  return nk.storage_write(
    {
      {
        collection = collection,
        key = avatar,
        user_id = user_id,
        value = farm_grid,
        permission_read = 2,
        permission_write = 0
      }
    }
  )
end

function log_method_call(name, context, payload)
  --nk.logger_info(name .. " called by " .. context.user_id .. " with: " .. payload)
end

local function forage(context, payload)
  log_method_call("farm_grid.forage", context, payload)
  local json = nk.json_decode(payload)
  local forage_call =
    M.forage(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(forage_call)
end

local function harvest(context, payload)
  log_method_call("farm_grid.harvest", context, payload)
  local json = nk.json_decode(payload)
  local harvest_call =
    M.harvest(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(harvest_call)
end

local function water(context, payload)
  log_method_call("farm_grid.water", context, payload)
  local json = nk.json_decode(payload)
  local water_call =
    M.water_plant(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(water_call)
end

local function till(context, payload)
  log_method_call("farm_grid.till", context, payload)
  local json = nk.json_decode(payload)
  local till_call =
    M.till(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y
  )

  return nk.json_encode(till_call)
end

local function detill(context, payload)
  log_method_call("farm_grid.detill", context, payload)
  local json = nk.json_decode(payload)
  local till_call =
    M.detill(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y
  )

  return nk.json_encode(till_call)
end

local function plant(context, payload)
  log_method_call("farm_grid.plant", context, payload)
  local json = nk.json_decode(payload)
  local plant_call =
    M.plant(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(plant_call)
end

local function cleanup(context, payload)
  log_method_call("farm_grid.cleanup", context, payload)
  local json = nk.json_decode(payload)
  local cleanup_call = M.cleanup(context.user_id, json.farm_owner_id, json.farm_owner_avatar, json.farm_collection)

  return nk.json_encode(cleanup_call)
end

local function place_crafted_item(context, payload)
  log_method_call("farm_grid.place_crafted_items", context, payload)
  local json = nk.json_decode(payload)
  local place_call =
    M.place_crafted_item(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(place_call)
end

local function remove_crafted_item(context, payload)
  log_method_call("farm_grid.place_crafted_items", context, payload)
  local json = nk.json_decode(payload)
  local remove_call =
    M.remove_crafted_item(
    context.user_id,
    json.avatar,
    json.farm_owner_id,
    json.farm_owner_avatar,
    json.farm_collection,
    json.x,
    json.y,
    json.metadata
  )

  return nk.json_encode(remove_call)
end

nk.register_rpc(forage, "farm_grid.forage")
nk.register_rpc(harvest, "farm_grid.harvest")
nk.register_rpc(till, "farm_grid.till")
nk.register_rpc(detill, "farm_grid.detill")
nk.register_rpc(plant, "farm_grid.plant")
nk.register_rpc(cleanup, "farm_grid.cleanup")
nk.register_rpc(water, "farm_grid.water")
nk.register_rpc(place_crafted_item, "farm_grid.place_crafted_item")
nk.register_rpc(remove_crafted_item, "farm_grid.remove_crafted_item")

return M
