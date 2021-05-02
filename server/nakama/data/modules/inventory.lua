local nk = require("nakama")
local items = require("inventory_items")
local validator = require("item_validation")

local M = {}

function M.has_item(user_id, avatar, item, quantity)
  local inventory = get_inventory(user_id, avatar)
  local has_item = false
  quantity = quantity or 1

  for _, i in ipairs(inventory.bag) do
    if (i.itemTypeId == item and i.quantity >= quantity) then
      has_item = true
    end
  end

  return has_item
end

function M.add_item(user_id, avatar, item, quantity, validate, context)
  local inventory = get_inventory(user_id, avatar)
  local has_item = false
  local bagPosition = nil
  local knownBagPositions = {}
  quantity = quantity or 1

  if (validate) then
    if M.perform_add_validations(user_id, avatar, item, inventory, context) == false then
      return false
    end
  end

  for _, i in ipairs(inventory.bag) do
    if (i.itemTypeId == item) then
      i.quantity = i.quantity + quantity
      has_item = true
    end

    knownBagPositions[tonumber(i.bagPosition)] = true
  end

  for i = 0, table.getn(inventory.bag) - 1, 1 do
    if (knownBagPositions[i] == nil) then
      bagPosition = i
      break
    end
  end

  if (bagPosition == nil) then
    bagPosition = table.getn(inventory.bag)
  end

  if (has_item == false) then
    table.insert(
      inventory.bag,
      {
        itemTypeId = item,
        bagPosition = bagPosition,
        quantity = quantity
      }
    )
  end

  save_inventory(user_id, avatar, inventory)

  return inventory
end

function M.perform_add_validations(user_id, avatar, item, inventory, context)
  local validatorFn = validator[items[item].key]
  local decodedContext = nil

  if validatorFn == nil then
    return false
  end

  if context ~= nil then
    decodedContext = nk.json_decode(context)
  end

  return validatorFn(user_id, avatar, inventory.bag, decodedContext)
end

function M.remove_item(user_id, avatar, item, quantity)
  local inventory = get_inventory(user_id, avatar)
  quantity = quantity or 1

  for _, i in ipairs(inventory.bag) do
    if (i.itemTypeId == item) then
      if (i.quantity > 1) then
        i.quantity = i.quantity - quantity
        if (i.quantity < 1) then
          table.remove(inventory.bag, _)
        end
      else
        table.remove(inventory.bag, _)
      end
    end
  end

  save_inventory(user_id, avatar, inventory)

  return inventory
end

function M.move_item(user_id, avatar, old_bag_position, bag_position)
  local inventory = get_inventory(user_id, avatar)

  local oldItem, item, temp

  for _, i in ipairs(inventory.bag) do
    if i.bagPosition == old_bag_position then
      oldItem = i
    elseif i.bagPosition == bag_position then
      item = i
    end
  end

  if item then
    item.bagPosition = old_bag_position
  end
  if oldItem then
    oldItem.bagPosition = bag_position
  end

  save_inventory(user_id, avatar, inventory)

  return inventory
end

function M.get_inventory(user_id, avatar)
  return get_inventory(user_id, avatar)
end

function M.save_inventory(user_id, avatar, inventory)
  return save_inventory(user_id, avatar, inventory)
end

function get_inventory(user_id, avatar)
  return nk.storage_read(
    {
      {
        collection = "inventoryBag",
        key = avatar,
        user_id = user_id
      }
    }
  )[1].value
end

function save_inventory(user_id, avatar, inventory)
  return nk.storage_write(
    {
      {
        collection = "inventoryBag",
        key = avatar,
        user_id = user_id,
        value = inventory,
        permission_read = 2,
        permission_write = 0
      }
    }
  )
end

function log_method_call(name)
  --nk.logger_info(name .. " called by " .. context.user_id .. " with: " .. payload)
end

local function add_item(context, payload)
  log_method_call("inventory.add_item", context, payload)
  local json = nk.json_decode(payload)
  local add_call = M.add_item(context.user_id, json.avatar, json.item, json.quantity, true, json.context)

  return nk.json_encode(add_call)
end

local function remove_item(context, payload)
  log_method_call("inventory.remove_item", context, payload)
  local json = nk.json_decode(payload)
  local remove_call = M.remove_item(context.user_id, json.avatar, json.item, json.quantity)

  return nk.json_encode(remove_call)
end

local function move_item(context, payload)
  log_method_call("inventory.move_item", context, payload)
  local json = nk.json_decode(payload)
  local move_call = M.move_item(context.user_id, json.avatar, json.oldBagPosition, json.bagPosition)

  return nk.json_encode(move_call)
end

nk.register_rpc(add_item, "inventory.add_item")
nk.register_rpc(remove_item, "inventory.remove_item")
nk.register_rpc(move_item, "inventory.move_item")

return M
