local nk = require("nakama")
local items = require("inventory_items")
local inventory = require("inventory")
local wallet = require("wallet")

local function purchase_item(context, payload)
  local info = nk.json_decode(payload)

  local item = items[items.reverse[info["item"]]]

  if (item.purchaseValidation) then
    if
      inventory.perform_add_validations(
        context.user_id,
        info.avatar,
        items.reverse[info["item"]],
        inventory.get_inventory(context.user_id, info.avatar),
        nil
      ) == false
     then
      return "false"
    end
  end

  if (item.comboPrice == true) then
    for _, p in ipairs(item.price) do
      if can_pay(p.itemKey, item, context.user_id, info.avatar, p.quantity) == false then
        return "false"
      end
    end

    for _, p in ipairs(item.price) do
      if charge_or_deduct(p.itemKey, item, context.user_id, info.avatar) == false then
        return "false"
      end
    end
  else
    if charge_or_deduct(info.currency, item, context.user_id, info.avatar) == false then
      return "false"
    end
  end

  inventory.add_item(context.user_id, info["avatar"], items.reverse[info["item"]], 1)
  return "true"
end

function can_pay(currency, item, user_id, avatar, quantity)
  if (currency == "CommunityCoin" or currency == "CorpusCoin") then
    return wallet.can_pay(user_id, avatar, currency, quantity)
  else
    return inventory.has_item(user_id, avatar, items.reverse[currency], quantity)
  end

  return false
end

function charge_or_deduct(currency, item, user_id, avatar)
  if (currency == "CommunityCoin" or currency == "CorpusCoin") then
    return wallet_charge(currency, item, user_id, avatar)
  else
    return deduct_item(currency, item, user_id, avatar)
  end

  return false
end

function deduct_item(item_to_deduct, item, user_id, avatar)
  local is_payable_with_currency = false
  local required_quantity = 0

  for _, p in ipairs(item.price) do
    if (p.itemKey == item_to_deduct) then
      is_payable_with_currency = true
      required_quantity = p.quantity
    end
  end

  if (is_payable_with_currency == false) then
    return false
  end

  if (inventory.has_item(user_id, avatar, items.reverse[item_to_deduct], required_quantity) == false) then
    return false
  end

  inventory.remove_item(user_id, avatar, items.reverse[item_to_deduct], required_quantity)
  return true
end

function wallet_charge(type, item, user_id, avatar)
  for _, p in ipairs(item.price) do
    if (p.itemKey == type) then
      return wallet.pay(user_id, avatar, type, p.quantity, {type = "item purchase"})
    end
  end

  return false
end

local function sell_item(context, payload)
  local info = nk.json_decode(payload)

  local item = items[items.reverse[info["item"]]]
  local itemKey = items.reverse[info["item"]]

  if (inventory.has_item(context.user_id, info.avatar, itemKey) == false) then
    return "false"
  end

  if (info.currency == "CommunityCoin" or info.currency == "CorpusCoin") then
    for _, p in ipairs(item.sale) do
      if (p.itemKey == info.currency) then
        if (wallet.fund(context.user_id, info.avatar, info.currency, p.quantity, {type = "item sale"}, false) == false) then
          return "false"
        end
      end
    end
  else
    local is_payable_with_currency = false
    local required_quantity = 0

    for _, p in ipairs(item.sale) do
      if (p.itemKey == info.currency) then
        is_payable_with_currency = true
        required_quantity = p.quantity
      end
    end

    if (is_payable_with_currency == false) then
      return "false"
    end

    inventory.add_item(context.user_id, info["avatar"], itemKey, required_quantity)
  end

  inventory.remove_item(context.user_id, info["avatar"], itemKey, 1)
  return "true"
end

local function get_prices(context, payload)
  local priced_items = {}

  for k, v in pairs(items) do
    if (k ~= "reverse") then
      if (v.price ~= nil or v.sale ~= nil) then
        priced_items[k] = v
      end
    end
  end

  return nk.json_encode(priced_items)
end

nk.register_rpc(purchase_item, "pos.purchase_item")
nk.register_rpc(sell_item, "pos.sell_item")
nk.register_rpc(get_prices, "pos.get_prices")
