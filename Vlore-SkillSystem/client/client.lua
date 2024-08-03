ESX = exports['es_extended']:getSharedObject()

local skills = {}

local function xpSync()
    local synced = false
    ESX.TriggerServerCallback('Vlore-SkillSystem:CheckLevel', function(levels)
        if levels == false then return end
        for k, v in pairs(levels) do
            skills[k] = v
            synced = true
        end
    end)
    local i = 0
    while not synced or i == 50 do
        i += 1
        Wait(100)
    end
    return synced
end

CreateThread(function() -- Aktualizowanie Statystyk
    while true do
        Wait(1000)
        xpSync()
        local wallet = exports.ox_inventory:GetSlotWithItem('money')
        StatSetInt("MP0_WALLET_BALANCE", wallet.count, true)
        local PlayerData = ESX.GetPlayerData()
        local account = 0
        for k, v in ipairs(PlayerData.accounts) do
            for kk, vv in pairs(v) do
                if kk == 'name' then
                    if vv == 'bank' then
                        account = k
                    end
                end
            end
        end
        StatSetInt("BANK_BALANCE", PlayerData.accounts[account].money, true)
        for k, v in pairs(skills) do
            if k == 'Stress' then
                StatSetFloat(Config.Skills[k].GtaStatName, v + 0.0, false)
            else
                StatSetInt(Config.Skills[k].GtaStatName, math.floor(v), true)
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    xpSync()
end)
