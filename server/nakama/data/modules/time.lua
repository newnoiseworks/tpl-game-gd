local nk = require("nakama")
local config = require("game_config")

local REAL_WORLD_SECONDS_PER_GAME_DAY = tonumber(config["real_world_seconds_per_in_game_day"])

local M = {}

function M.number_of_game_days_from_daybreak_unix_timestamp(timestamp)
  currentTime = M.get_current_timestamp() / 1000
  return math.floor(
    (currentTime - M.unix_timestamp_start_of_gameday_from_seconds(timestamp)) /
      REAL_WORLD_SECONDS_PER_GAME_DAY
  )
end

function M.unix_timestamp_start_of_gameday_from_seconds(seconds)
  return (seconds - (seconds % REAL_WORLD_SECONDS_PER_GAME_DAY)) + (REAL_WORLD_SECONDS_PER_GAME_DAY / 4)
end

function M.get_current_timestamp()
  return nk.time()
end

local function get_server_time(context, payload)
  return nk.json_encode(M.get_current_timestamp())
end

nk.register_rpc(get_server_time, "get_server_time")

return M
