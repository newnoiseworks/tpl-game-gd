local nk = require("nakama")
local items = require("inventory_items")

local V = {}

function get_farm_grid(user_id, avatar, collection)
  local farm =
    nk.storage_read(
    {
      {
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

function validate_forage_drop(user_id, avatar, bag, context, drop_type)
  local farm_grid = get_farm_grid(context.farm_owner_id, context.farm_owner_avatar, context.farm_owner_collection)

  local hasForageObject = false

  for _, f in ipairs(farm_grid.forageItems) do
    -- TODO: add the below clause for health tracking if we can avoid race conditions at some point
    -- and f.health <= 0)
    if (f.x == tonumber(context.x) and f.y == tonumber(context.y) and f.type == tonumber(context.forage_item_type)) then
      -- TODO: validate against dropItems
      hasForageObject = true
      break
    end
  end

  return hasForageObject
end

function validate_has_blueprint(user_id, avatar, bag, context, blueprint_type)
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

  local has_blueprint = false

  for _, b in ipairs(reatomizer.blueprints) do
    if b == items.reverse[blueprint_type] then
      has_blueprint = true
    end
  end

  return has_blueprint
end

function validate_mission_drop(user_id, avatar, bag, context, type, mission_key)
  local mission_data = get_missions(user_id, avatar)

  local is_mission_current = false

  for _, mission in ipairs(mission_data.missions) do
    if mission.key == mission_key and mission.finished == 0 then
      is_mission_current = true

      if context.meta ~= nil then
        if mission.context == nil then
          mission.context = {}
        end

        table.insert(mission.context, context.meta)
      end

      break
    end
  end

  save_mission_data(user_id, avatar, mission_data)

  return is_mission_current
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

V["Stone"] = function(user_id, avatar, bag, context)
  return validate_forage_drop(user_id, avatar, bag, context, "Stone")
end

V["Fern"] = function(user_id, avatar, bag, context)
  return validate_forage_drop(user_id, avatar, bag, context, "Fern")
end

V["Wood"] = function(user_id, avatar, bag, context)
  return validate_forage_drop(user_id, avatar, bag, context, "Wood")
end

V["Crafted_StonePath"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_StonePath")
end

V["Crafted_WoodPath"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_WoodPath")
end

V["Crafted_Lamp"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Lamp")
end

V["Crafted_Lamp2"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Lamp2")
end

V["Crafted_Lamp3"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Lamp3")
end

V["Crafted_Lamp4"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Lamp4")
end

V["Crafted_Lamp5"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Lamp5")
end

V["Crafted_SittingGnome"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_SittingGnome")
end

V["Crafted_SittingGnome2"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_SittingGnome2")
end

V["Crafted_StandingGnome"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_StandingGnome")
end

V["Crafted_StandingGnome2"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_StandingGnome1")
end

V["Crafted_StonePile"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_StonePile")
end

V["Crafted_ModernStatue"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_ModernStatue")
end

V["Crafted_Scarecrow"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Scarecrow")
end

V["Crafted_Spook"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Spook")
end

V["Crafted_Spook2"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Spook2")
end

V["Crafted_Flamingo"] = function(user_id, avatar, bag, context)
  return validate_has_blueprint(user_id, avatar, bag, context, "Blueprint_Flamingo")
end

V["YorkHeart"] = function(user_id, avatar, bag, context)
  return validate_mission_drop(user_id, avatar, bag, context, "YorkHeart", "pickupYorksHearts")
end

V["Fish"] = function(user_id, avatar, bag, context)
  return true
end

return V
