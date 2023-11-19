local nk = require("nakama")
local mission_list = require("mission_list")
local inventory = require("inventory")
local items = require("inventory_items")
local wallet = require("wallet")
local M = {}

M.complete = function(user_id, avatar, data)
  local user_mission_data = get_missions(user_id, avatar)

  for _, mission in ipairs(user_mission_data.missions) do
    if mission.key == data.key then
      local mission_data = mission_list[mission.key]
      if mission_data.reqs ~= nil then
        if can_pass_mission_requirements(data.key, user_id, avatar) then

          for _, req in ipairs(mission_data.reqs) do
            inventory.remove_item(user_id, avatar, req.key, req.quantity)
          end

          distribute_awards(user_id, avatar, mission_data)
          mission.finished = 1
        else
          return false
        end
      else
        distribute_awards(user_id, avatar, mission_data)
        mission.finished = 1
      end

      break
    end
  end

  save_mission_data(user_id, avatar, user_mission_data)

  return true
end

function distribute_awards(user_id, avatar, mission)
  if mission.awards ~= nil then
    for _, award in ipairs(mission.awards) do
      if string.match(items[award.key].key, "Coin") then
        wallet.fund(user_id, avatar, items[award.key].key, award.quantity, {type="award from mission"})
      else
        inventory.add_item(user_id, avatar, award.key, award.quantity)
      end
    end
  end
end

M.start = function(user_id, avatar, data)
  local mission_data = get_missions(user_id, avatar)

  table.insert(mission_data.missions, {
    key = data.key,
    finished = 0
  })

  save_mission_data(user_id, avatar, mission_data)

  return true
end

function can_pass_mission_requirements(mission_key, user_id, avatar)
  local mission = mission_list[mission_key]

  for _, req in ipairs(mission.reqs) do
    if (inventory.has_item(user_id, avatar, req.key, req.quantity) == false) then
      return false
    end
  end

  if mission.awards ~= nil then
    for _, award in ipairs(mission.reqs) do
      if string.match(items[award.key].key, "Coin") == false then
        -- TODO: Check to see if you can add inventory items here based on available space
      end
    end
  end

  return true
end

function save_mission_data(user_id, avatar, mission_data)
  return nk.storage_write({
    {
      collection = "missionData",
      key = avatar,
      user_id = user_id,
      value = mission_data,
      permission_read = 2,
      permission_write = 0
    }
  })
end

function get_missions(user_id, avatar)
  return nk.storage_read({
    {
      collection = "missionData",
      key = avatar,
      user_id = user_id
    }
  })[1].value
end

local function complete_mission(context, payload)
  local json = nk.json_decode(payload)

  return nk.json_encode(M.complete(context.user_id, json.avatar, json))
end

local function start_mission(context, payload)
  local json = nk.json_decode(payload)

  return nk.json_encode(M.start(context.user_id, json.avatar, json))
end

nk.register_rpc(complete_mission, "missions.complete")
nk.register_rpc(start_mission, "missions.start")

return M