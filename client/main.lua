local Framework = nil
local PlayerData = {}

if GetResourceState('es_extended') == 'started' then
    Framework = 'ESX'
    ESX = exports["es_extended"]:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'QB'
    QBCore = exports['qb-core']:GetCoreObject()
end

local function isProtectedItem(itemName)
    for _, protectedItem in pairs(Config.ProtectedItems) do
        if itemName == protectedItem then
            return true
        end
    end
    return false
end

if Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
    end)
elseif Framework == 'QB' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)
end

RegisterNetEvent('fearx-antirob:showNotification')
AddEventHandler('fearx-antirob:showNotification', function(message, type)
    if Config.EnableNotifications then
        lib.notify({
            title = 'Anti-Rob System',
            description = message,
            type = type or 'inform'
        })
    end
end)