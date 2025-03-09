RegisterNetEvent('stoc:duty', function(isOnDuty)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if Player.PlayerData.job.name == Config.JobName then
        Player.Functions.SetJobDuty(isOnDuty)
    end
end)

RegisterNetEvent('stoc:getEquipment', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if Player.PlayerData.job.name == Config.JobName then
        exports.ox_inventory:AddItem(src, Config.Equipment.primaryWeapon, 1)
        exports.ox_inventory:AddItem(src, Config.Equipment.secondaryWeapon, 1)
        exports.ox_inventory:AddItem(src, Config.Equipment.armor, 1)
        for _, item in pairs(Config.Equipment.items) do
            exports.ox_inventory:AddItem(src, item.name, item.count)
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'STOC Equipment',
            description = 'You have received your equipment.',
            icon = 'check',
            iconColor = '#008000'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'STOC Equipment',
            description = 'You are not a member of the STOC.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end)

RegisterNetEvent('stoc:storeEquipment', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if Player.PlayerData.job.name == Config.JobName then
        local primaryWeaponCount = exports.ox_inventory:GetItem(src, Config.Equipment.primaryWeapon, nil, true)
        if primaryWeaponCount > 0 then
            exports.ox_inventory:RemoveItem(src, Config.Equipment.primaryWeapon, 1)
        end

        local secondaryWeaponCount = exports.ox_inventory:GetItem(src, Config.Equipment.secondaryWeapon, nil, true)
        if secondaryWeaponCount > 0 then
            exports.ox_inventory:RemoveItem(src, Config.Equipment.secondaryWeapon, 1)
        end

        local armorCount = exports.ox_inventory:GetItem(src, Config.Equipment.armor, nil, true)
        if armorCount > 0 then
            exports.ox_inventory:RemoveItem(src, Config.Equipment.armor, 1)
        end

        for _, item in pairs(Config.Equipment.items) do
            local itemCount = exports.ox_inventory:GetItem(src, item.name, nil, true)
            if itemCount > 0 then
                local amountToRemove = math.min(item.count, itemCount)
                exports.ox_inventory:RemoveItem(src, item.name, amountToRemove)
            end
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'STOC Equipment',
            description = 'You have stored your equipment.',
            icon = 'check',
            iconColor = '#008000'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'STOC Equipment',
            description = 'You are not a member of the STOC.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if Player.PlayerData.job.name == Config.JobName and Config.ReduceStressOnShoot then
        TriggerClientEvent('hud:client:RelieveStress', src, amount)
    end
end)

RegisterNetEvent('militaryjob:setCallsign', function(targetId, callsign)
    local src = source
    local targetPlayer = exports.qbx_core:GetPlayer(targetId)

    if targetPlayer then
        targetPlayer.Functions.SetMetaData("callsign", callsign)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'STOC System',
            description = 'Successfully set callsign for ' .. targetId .. ' callsign: ' .. callsign,
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'check',
            iconColor = '#008000'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'STOC System',
            description = 'Player not found!',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end)

RegisterNetEvent('stoc:server:SearchPlayer', function(targetSrc)
    if isTargetTooFar(source, targetSrc) then return end

    local targetPlayer = exports.qbx_core:GetPlayer(targetSrc)
    if not targetPlayer then return end
end)

local function notifyOfficers(message, coords)
    local players = exports.qbx_core:GetQBPlayers()
    for _, player in pairs(players) do
        if player and player.PlayerData.job.name == 'stoc' and player.PlayerData.job.onduty then
            TriggerClientEvent('ox_lib:notify', player.PlayerData.source, {
                title = 'Panic Button',
                description = message,
                style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
                icon = 'info',
                iconColor = '#C20E0F',
                duration = Config.PanicButtonDuration,
            })
            TriggerClientEvent('stoc:panicBlip', player.PlayerData.source, coords)
        end
    end
end

RegisterServerEvent('stoc:panicButton')
AddEventHandler('stoc:panicButton', function()
    local playerId = source
    local player = exports.qbx_core:GetPlayer(playerId)

    if player and player.PlayerData.job.name == 'stoc' and player.PlayerData.job.onduty then
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        notifyOfficers(
         'Agent ' .. player.PlayerData.charinfo.firstname ..
        ' ' .. player.PlayerData.charinfo.lastname .. ' | ' .. player.PlayerData.metadata.callsign .. ' Down!', playerCoords)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'STOC System',
            description = 'You must be on duty to use panic button.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end, false)

