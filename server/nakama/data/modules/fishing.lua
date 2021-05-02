local nk = require("nakama")
local inventory = require("inventory")
local F = {}

F.cast_lure = function(user_id, avatar)
  -- eventually lookup their inventory, check up fishing pole etc

  return {
    timeDelay = math.random(5, 20),
    weight = math.random(5, 30)
  }
end

local function cast_lure(context, payload)
  local lure_call = F.cast_lure(context.user_id, payload)

  return nk.json_encode(lure_call)
end

nk.register_rpc(cast_lure, "fishing.cast_lure")

return F
