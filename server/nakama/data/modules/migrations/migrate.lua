local nk = require("nakama")
local items = require("inventory_items")

local admin_user_id = "admin"

local migration_table = "tpv_migrations"

-- THIS IS WHAT NEEDS TO REFLECT THE LATEST DATE POST MIGRATION
local migration_version_date = "01082020"

-- THIS IS WHERE YOU MAKE MIGRATIONS HAPPEN
function latest_migration(user_id)
  iterate_over_avatars(
    user_id,
    function(avatar)
      nk.storage_write(
        {
          {
            collection = "town0CommunityFarmGrid",
            key = avatar.key,
            user_id = user_id,
            value = {},
            permission_read = 2,
            permission_write = 0
          }
        }
      )
    end
  )

  migration_completed()
end

local function check_for_migration_files()
  create_migration_table_if_needed()

  if (needs_migration()) then
    perform_migrations()
  end
end

function create_migration_table_if_needed()
  nk.sql_exec(
    [[CREATE TABLE IF NOT EXISTS ]] ..
      migration_table .. [[ (
    id INT PRIMARY KEY,
    key STRING,
    value STRING
  )]]
  )
end

function needs_migration()
  local query = [[SELECT value
    FROM ]] .. migration_table .. [[
    WHERE key = 'latest' AND id = 1
    LIMIT 1]]
  local parameters = {}
  local rows = nk.sql_query(query, parameters)

  local has_updated = false

  for _, m in ipairs(rows) do
    if (m.value == migration_version_date) then
      has_updated = true
    end
  end

  return has_updated == false
end

function migration_completed()
  nk.sql_exec(
    [[UPSERT INTO ]] ..
      migration_table ..
        [[ (
    id, key, value
  ) VALUES (
    1, 'latest', ']] .. migration_version_date .. [['
  )]]
  )
end

function perform_migrations()
  local query = [[SELECT id
    FROM users
  ]]
  local parameters = {}
  local rows = nk.sql_query(query, parameters)

  nk.logger_info("Updating " .. #rows .. " users.")
  for i, row in ipairs(rows) do
    nk.logger_info("Migrating user w/ id " .. row.id)
    latest_migration(row.id)
  end
end

function iterate_over_avatars(user_id, callback)
  local profile =
    nk.storage_read(
    {
      {
        collection = "profile",
        key = "A11",
        user_id = user_id
      }
    }
  )

  for _, p in ipairs(profile) do
    for _, a in ipairs(p.value.avatars) do
      callback(a)
    end
  end
end

nk.run_once(check_for_migration_files)
