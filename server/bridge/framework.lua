local qbx = exports.qbx_core

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    TriggerEvent(('%s:playerLoaded'):format(GetCurrentResourceName()), source)
end)

AddEventHandler('qbx_core:server:playerLoaded', function(playerId)
    TriggerEvent(('%s:playerLoaded'):format(GetCurrentResourceName()), playerId)
end)

BRIDGE.GetPlayerData = function(playerId)
    return qbx:GetPlayer(playerId)
end

BRIDGE.GetPlayerJob = function(playerId)
    local player = qbx:GetPlayer(playerId)
    return player and player.PlayerData.job.name or nil
end

BRIDGE.GetPlayerGang = function(playerId)
    local player = qbx:GetPlayer(playerId)
    return player and player.PlayerData.gang.name or nil
end

BRIDGE.AddSocietyMoney = function(jobName, money)
    exports.qbx_management:AddMoney(jobName, money)
end

BRIDGE.RegisterUsableItem = function(itemName, clientEvent)
    exports.qbx_core:CreateUseableItem(itemName, function(source, item)
        TriggerClientEvent(clientEvent, source, { item = item })
    end)
end
