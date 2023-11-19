local nk = require("nakama")

local function get_version(context, payload)
  return nk.json_encode({
    ["game"] = "local",
  })
end

nk.register_rpc(get_version, "get_version")
