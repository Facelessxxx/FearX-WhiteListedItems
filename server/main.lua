local Framework = nil
local PlayerData = {}

if GetResourceState('es_extended') == 'started' then
    Framework = 'ESX'
    ESX = exports["es_extended"]:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'QB'
    QBCore = exports['qb-core']:GetCoreObject()
end

local function GetPlayer(source)
    if Framework == 'ESX' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'QB' then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end

local function ShowNotification(player, message, type)
    if not player then return end
    
    if Framework == 'ESX' then
        player.showNotification(message, type)
    elseif Framework == 'QB' then
        TriggerClientEvent('ox_lib:notify', player.PlayerData.source, {
            title = 'Anti-Rob System',
            description = message,
            type = type
        })
    end
end

local function isProtectedItem(itemName)
    for _, protectedItem in pairs(Config.ProtectedItems) do
        if itemName == protectedItem then
            return true
        end
    end
    return false
end

local function sendDiscordLog(robber, victim, item, amount)
    if not Config.LogRobAttempts or Config.Discord.webhook == '' then
        return
    end
    
    local embed = {
        {
            color = Config.Discord.color,
            title = Config.Discord.title,
            description = string.format("**Robber:** %s (%s)\n**Victim:** %s (%s)\n**Item:** %s\n**Amount:** %s", 
                GetPlayerName(robber), 
                GetPlayerIdentifier(robber, 0),
                GetPlayerName(victim),
                GetPlayerIdentifier(victim, 0),
                item,
                amount
            ),
            footer = {
                text = Config.Discord.footer
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

local function createProtectedItemFilter()
    local filter = {}
    for _, item in pairs(Config.ProtectedItems) do
        filter[item] = true
    end
    return filter
end

local function isNumericString(str)
    return string.match(tostring(str), "^%d+$") ~= nil
end

local swapHookId = exports.ox_inventory:registerHook('swapItems', function(payload)
    if not payload or not payload.fromInventory or not payload.toInventory or not payload.fromSlot then
        return true
    end
    
    local fromSlot = payload.fromSlot
    if not fromSlot.name or not isProtectedItem(fromSlot.name) then
        return true
    end
    
    local fromInventory = tostring(payload.fromInventory)
    local toInventory = tostring(payload.toInventory)
    
    if isNumericString(fromInventory) then
        local fromPlayerId = tonumber(fromInventory)
        local fromPlayer = GetPlayer(fromPlayerId)
        
        if fromPlayer then
            if isNumericString(toInventory) then
                local toPlayerId = tonumber(toInventory)
                
                if toPlayerId ~= fromPlayerId then
                    if Config.EnableNotifications then
                        ShowNotification(fromPlayer, Config.Notifications.protectedItem.description, Config.Notifications.protectedItem.type)
                        local toPlayer = GetPlayer(toPlayerId)
                        if toPlayer then
                            ShowNotification(toPlayer, Config.Notifications.robAttempt.description, Config.Notifications.robAttempt.type)
                        end
                    end
                    
                    sendDiscordLog(fromPlayerId, toPlayerId, fromSlot.name, fromSlot.count)
                    return false
                end
            else
                if toInventory == 'newdrop' then
                    if Config.EnableNotifications then
                        ShowNotification(fromPlayer, 'This item cannot be dropped', 'error')
                    end
                    return false
                elseif not isNumericString(toInventory) then
                    if Config.EnableNotifications then
                        ShowNotification(fromPlayer, 'This item cannot be moved to containers', 'error')
                    end
                    return false
                end
            end
        end
    end
    
    return true
end, {
    itemFilter = createProtectedItemFilter()
})

lib.addCommand('addprotected', {
    help = 'Add item to protected list',
    params = {
        {
            name = 'item',
            type = 'string',
            help = 'Item name to protect'
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local itemName = args.item
    
    if not isProtectedItem(itemName) then
        table.insert(Config.ProtectedItems, itemName)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Success',
            description = 'Item ' .. itemName .. ' added to protected list',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Item ' .. itemName .. ' is already protected',
            type = 'error'
        })
    end
end)

lib.addCommand('removeprotected', {
    help = 'Remove item from protected list',
    params = {
        {
            name = 'item',
            type = 'string',
            help = 'Item name to unprotect'
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local itemName = args.item
    
    for i, protectedItem in pairs(Config.ProtectedItems) do
        if protectedItem == itemName then
            table.remove(Config.ProtectedItems, i)
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Success',
                description = 'Item ' .. itemName .. ' removed from protected list',
                type = 'success'
            })
            return
        end
    end
    
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Error',
        description = 'Item ' .. itemName .. ' is not in protected list',
        type = 'error'
    })
end)

lib.addCommand('listprotected', {
    help = 'List all protected items',
    restricted = 'group.admin'
}, function(source)
    local itemList = table.concat(Config.ProtectedItems, ', ')
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Protected Items',
        description = itemList,
        type = 'inform',
        duration = 10000
    })
end)