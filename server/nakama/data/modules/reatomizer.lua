local nk = require("nakama")
local inventory = require("inventory")
local M = {}

M.add_blueprint = function(user_id, avatar, blueprint)
  local atomizer = get_atomizer(user_id, avatar)
  local has_blueprint = false

  local has_item = inventory.has_item(user_id, avatar, blueprint, 1)

  if has_item == false then
    return false
  end

  for _, b in ipairs(atomizer.blueprints) do
    if b == blueprint then
      has_blueprint = true
    end
  end

  if (has_blueprint) then
    return false
  end

  table.insert(atomizer.blueprints, blueprint)

  inventory.remove_item(user_id, avatar, blueprint, 1)
  save_atomizer(user_id, avatar, atomizer)

  return atomizer
end

function get_atomizer(user_id, avatar)
  local reatomizer =
    nk.storage_read(
    {
      {
        collection = "reatomizer",
        key = avatar,
        user_id = user_id
      }
    }
  )[1].value

  return reatomizer
end

function save_atomizer(user_id, avatar, atomizer)
  return nk.storage_write(
    {
      {
        collection = "reatomizer",
        key = avatar,
        user_id = user_id,
        value = atomizer,
        permission_read = 2,
        permission_write = 0
      }
    }
  )
end

local function add_blueprint(context, payload)
  local json = nk.json_decode(payload)
  local till_call = M.add_blueprint(context.user_id, json.avatar, json.blueprint)

  return nk.json_encode(till_call)
end

nk.register_rpc(add_blueprint, "reatomizer.add_blueprint")

return M
