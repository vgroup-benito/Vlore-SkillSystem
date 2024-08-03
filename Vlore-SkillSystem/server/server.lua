ESX = exports['es_extended']:getSharedObject()

local defaultTable = {}
local reput = {}

local function count(tbl)
    local total = 0

    for _, __ in pairs(tbl) do
        total = total + 1
    end
    return total
end

function xpCheck(identifier)
    if reput[identifier] then return reput[identifier] end
    local xp = MySQL.scalar.await('SELECT `skillsystem` FROM `users` WHERE `identifier` = ? LIMIT 1', {
        identifier
    })
    if xp == nil then xpModify(identifier, defaultTable) return xpCheck(identifier) end
    reput[identifier] = json.decode(xp)
    local contains = {}
    for k, v in pairs(reput[identifier]) do
        for kk, vv in pairs(Config.Skills) do
            if kk == k then
                contains[kk] = true
            end
        end
    end
    local new_table_to_set = {}
    for k, v in pairs(defaultTable) do
        new_table_to_set[k] = 0
    end
    for k, v in pairs(reput[identifier]) do
        if contains[k] then
            new_table_to_set[k] = v
        end
    end
    if count(contains) ~= count(reput[identifier]) then xpModify(identifier, new_table_to_set) return xpCheck(identifier) end
    return json.decode(xp)
end

function xpModify(identifier, value)
    if identifier == nil or value == nil then return error(identifier .. " " .. tonumber(value) .. " Sprawdź te wartości", 2) and false end
    MySQL.Sync.execute("UPDATE users SET skillsystem=@value WHERE identifier=@iden",{['@value'] = json.encode(value), ['@iden'] = identifier})
    reput[identifier] = value
end

function xpAdd(identifier, key, value)
    if identifier == nil or value == nil or key == nil then return error(identifier .. " " .. key .. " " .. tonumber(value) .. " Sprawdź te wartości", 2) and false end
    local table = reput[identifier]
    for k, v in pairs(table) do
        if k == key then
            table[k] = v + value
        end
    end
    if not table[key] then table[key] = value end
    xpModify(identifier, reput[identifier])
end

ESX.RegisterServerCallback('Vlore-SkillSystem:CheckLevel', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer == nil then return cb(false) end
    local iden = xPlayer.identifier
    cb(xpCheck(iden))
end)

exports('AddSkillPoints', xpAdd)

CreateThread(function()
    for k, v in pairs(Config.Skills) do
        defaultTable[k] = 0
    end
end)

MySQL.ready(function()
    MySQL.Sync.execute("ALTER TABLE `users` ADD COLUMN IF NOT EXISTS skillsystem longtext;")
end)