local nk = require("nakama")

local W = {}

local GREED_PROBABLY_NOT_BETTER_THAN_LIMIT = 100

local function can_pay(user_id, avatar_key, currency_type, amount)
  local account = nk.account_get_id(user_id)
  local coin = account.wallet[currency_type .. "-" .. avatar_key]

  if coin == nil then return false end

  return coin >= amount
end

W.can_pay = function(user_id, avatar_key, currency_type, amount)
  return can_pay(user_id, avatar_key, currency_type, amount)
end

W.pay = function(user_id, avatar_key, currency_type, amount, metadata)
  if (can_pay(user_id, avatar_key, currency_type, amount)) then
    local changeset = {
      [currency_type .. "-" .. avatar_key] = (-1 * amount)
    }

    metadata = metadata or {}

    nk.wallet_update(user_id, changeset, metadata, true)

    return true
  end

  return false
end

W.fund = function(user_id, avatar_key, currency_type, amount, metadata, corpus_only)
  metadata = metadata or {}
  corpus_only = corpus_only or false
  local changeset = {}

  if (currency_type == "CorpusCoin") then
    local account = nk.account_get_id(user_id)
    local coin = account.wallet[currency_type .. "-" .. avatar_key]

    if (coin + amount >= GREED_PROBABLY_NOT_BETTER_THAN_LIMIT) then
      local community_coin = (coin + amount) - GREED_PROBABLY_NOT_BETTER_THAN_LIMIT
      local corpus_coin = amount - community_coin

      if corpus_only then
        community_coin = 0
      end

      changeset = {
        ["CorpusCoin-" .. avatar_key] = corpus_coin,
        ["CommunityCoin-" .. avatar_key] = community_coin
      }
    else
      changeset[currency_type .. "-" .. avatar_key] = amount
    end
  else
    changeset = {
      [currency_type .. "-" .. avatar_key] = amount
    }
  end

  nk.wallet_update(user_id, changeset, metadata, true)
end

local function cheat_money(context, payload)
  W.fund(context.user_id, payload, "CorpusCoin", 100)
  W.fund(context.user_id, payload, "CommunityCoin", 1000)
end


nk.register_rpc(cheat_money, "wallet.cheat_money")

return W
