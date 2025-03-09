local isOnDuty = false
local rentedVehicles = {}
local rentedAircrafts = {}
local rentedHelicopters = {}

local function ToggleDuty()
    local playerJob = QBX.PlayerData.job
    if playerJob.name == Config.JobName then
        isOnDuty = not isOnDuty
        TriggerServerEvent('stoc:duty', isOnDuty)
        if Config.PanicEnabled then
            TriggerEvent('stoc:panicDuty', isOnDuty)
        end
        local message = isOnDuty and 'You are now Active' or 'You are now Offline'
        local color = isOnDuty and '#F29A2E' or '#C20E0F'
        local icon = isOnDuty and 'info' or 'ban'
        lib.notify({
            title = 'STOC Duty',
            description = message,
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = icon,
            iconColor = color
        })
    else
        lib.notify({
            title = 'STOC Duty',
            description = 'You are not a member of the STOC.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end

exports.ox_target:addSphereZone({
    coords = Config.DutyLocation,
    radius = 1.0,
    options = {
        {
            name = 'toggle_duty',
            icon = 'fa-solid fa-toggle-on',
            label = 'Toggle Duty',
            distance = 1.5,
            onSelect = function()
                if HasKeyItem() then
                    ToggleDuty()
                else
                    lib.notify({
                        title = 'STOC System',
                        description = 'You don\'t have a access keycard.',
                        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
                        icon = 'ban',
                        iconColor = '#C20E0F'
                    })
                end
            end,
        }
    }
})

local function GetEquipment()
    if not isOnDuty then
        lib.notify({
            title = 'STOC Equipment',
            description = 'You must be on duty to get equipment.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    TriggerServerEvent('stoc:getEquipment')
end

local function StoreEquipment()
    if not isOnDuty then
        lib.notify({
            title = 'STOC Equipment',
            description = 'You must be on duty to store equipment.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    TriggerServerEvent('stoc:storeEquipment')
end

exports.ox_target:addSphereZone({
    coords = Config.EquipmentLocation,
    radius = 1.0,
    options = {
        {
            name = 'get_equipment',
            icon = 'fa-solid fa-suitcase',
            label = 'Get Equipment',
            distance = 1.5,
            onSelect = function()
                if HasKeyItem() then
                    GetEquipment()
                else
                    lib.notify({
                        title = 'STOC System',
                        description = 'You don\'t have a access keycard.',
                        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
                        icon = 'ban',
                        iconColor = '#C20E0F'
                    })
                end
            end,
        },
        {
            name = 'store_equipment',
            icon = 'fa-solid fa-box-archive',
            label = 'Store Equipment',
            distance = 1.5,
            onSelect = StoreEquipment,
        }
    }
})

local function HandleStressReduction()
    while true do
        local playerPed = PlayerPedId()
        local playerJob = QBX.PlayerData.job

        if playerJob.name == Config.JobName and isOnDuty then
            if IsPedShooting(playerPed) then
                TriggerServerEvent('hud:server:RelieveStress', 0)
            end
        end
        Wait(1000)
    end
end

CreateThread(HandleStressReduction)

local function SpawnVehicle(model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        lib.notify({
            title = 'STOC System',
            description = 'Invalid vehicle model.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local spawnCoords = Config.VehicleSpawnLocation

    vehicleGarage = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    if DoesEntityExist(vehicleGarage) then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicleGarage, -1)
        SetVehicleColours(vehicleGarage, 0, 0)
        SetVehicleFuelLevel(vehicleGarage, 100.0)
        SetVehicleNumberPlateText(vehicleGarage, ('STOC' .. ' ' .. QBX.PlayerData.metadata.callsign))

        local plate = GetVehicleNumberPlateText(vehicleGarage)
        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

        rentedVehicles[plate] = vehicleGarage

        lib.notify({
            title = 'STOC Garage',
            description = 'Vehicle spawned and keys added to your inventory.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'check',
            iconColor = '#008000'
        })
    else
        lib.notify({
            title = 'STOC Garage',
            description = 'Failed to spawn vehicle.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end

    SetModelAsNoLongerNeeded(model)
end

local function StoreVehicle()

    local plate = GetVehicleNumberPlateText(vehicleGarage)
    local vehicle = rentedVehicles[plate]
    if not DoesEntityExist(vehicle) then
        lib.notify({
            title = 'STOC Garage',
            description = 'You don\'t have any vehicle rented .',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if not rentedVehicles[plate] then
        lib.notify({
            title = 'STOC Garage',
            description = 'This vehicle was not rented by you.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    DeleteEntity(vehicle)
    rentedVehicles[plate] = nil

    lib.notify({
        title = 'STOC Garage',
        description = 'Vehicle stored successfully.',
        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' }},
        icon = 'check',
        iconColor = '#008000'
    })
end

local function OpenGarageMenu()
    if not isOnDuty then
        lib.notify({
            title = 'STOC System',
            description = 'You must be on duty to open garage.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local playerJob = QBX.PlayerData.job
    if not playerJob or playerJob.name ~= Config.JobName then
        lib.notify({
            title = 'STOC System',
            description = 'You are not a member of the STOC.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local playerRank = playerJob.grade
    if type(playerRank) == 'table' then
        playerRank = playerRank.level or playerRank.grade
    end

    local vehicleOptions = {}
    for _, vehicle in pairs(Config.Vehicles) do
        if vehicle.rank <= playerRank then
            table.insert(vehicleOptions, {
                title = vehicle.label,
                description = 'Spawn a ' .. vehicle.label,
                onSelect = function()
                    SpawnVehicle(vehicle.model)
                end
            })
        end
    end

    table.insert(vehicleOptions, {
        title = 'Store Vehicle',
        description = 'Return your rented vehicle to the garage.',
        onSelect = StoreVehicle
    })

    if #vehicleOptions == 0 then
        lib.notify({
            title = 'STOC Garage',
            description = 'No vehicles available for your rank.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    lib.registerContext({
        id = 'stoc_garage_menu',
        title = 'STOC Garage',
        options = vehicleOptions
    })
    lib.showContext('stoc_garage_menu')
end

exports.ox_target:addSphereZone({
    coords = Config.GarageLocation,
    radius = 1.0,
    options = {
        {
            name = 'open_garage',
            icon = 'fa-solid fa-car',
            label = 'Open Garage',
            distance = 2.5,
            onSelect = function()
                if HasKeyItem() then
                    OpenGarageMenu()
                else
                    lib.notify({
                        title = 'STOC System',
                        description = 'You don\'t have a access keycard.',
                        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
                        icon = 'ban',
                        iconColor = '#C20E0F'
                    })
                end
            end,
        }
    }
})

local function openCallsignMenu()
    if not isOnDuty then
        lib.notify({
            title = 'STOC Equipment',
            description = 'You must be on duty to open callsign menu.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end
    if QBX.PlayerData.job.grade.level >= 2 then
        local input = lib.inputDialog('Set Callsign', {
            { type = 'number', label = 'Player ID', required = true },
            { type = 'input',  label = 'Callsign',  required = true }
        })

        if not input then return end

        local targetId = tonumber(input[1])
        local callsign = input[2]

        if targetId and callsign then
            TriggerServerEvent('militaryjob:setCallsign', targetId, callsign)
        else
            lib.notify({
                title = 'STOC System',
                description = 'Invalid input.',
                icon = 'ban',
                iconColor = '#C20E0F'
            })
        end
    else
        lib.notify({
            title = 'STOC System',
            description = 'You are not certified enough to change callsigns.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end
end

exports.ox_target:addSphereZone({
    coords = Config.CallSignLocation,
    radius = 1.0,
    options = {
        {
            name = 'open_callsign',
            icon = 'fa-solid fa-info',
            label = 'Set CallSign',
            distance = 1.5,
            onSelect = openCallsignMenu,
        }
    }
})

local function SpawnAircraft(model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        lib.notify({
            title = 'STOC Hangar',
            description = 'Invalid aircraft model.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local spawnCoords = Config.AircraftSpawnLocation

    aircraftGarage = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    if DoesEntityExist(aircraftGarage) then
        TaskWarpPedIntoVehicle(PlayerPedId(), aircraftGarage, -1)
        SetVehicleColours(aircraftGarage, 0, 0)
        SetVehicleFuelLevel(aircraftGarage, 100.0)

        local plate = GetVehicleNumberPlateText(aircraftGarage)
        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

        rentedAircrafts[plate] = aircraftGarage

        lib.notify({
            title = 'STOC Hangar',
            description = 'Aircraft spawned and keys added to your inventory.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'check',
            iconColor = '#008000'
        })
    else
        lib.notify({
            title = 'STOC Hangar',
            description = 'Failed to spawn aircraft.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end

    SetModelAsNoLongerNeeded(model)
end

local function StoreAircraft()
    local plate = GetVehicleNumberPlateText(aircraftGarage)
    local aircraft = rentedAircrafts[plate]
    if not DoesEntityExist(aircraft) then
        lib.notify({
            title = 'STOC Hangar',
            description = 'You don\'t have any aircraft rented .',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local plate = GetVehicleNumberPlateText(aircraft)
    if not rentedAircrafts[plate] then
        lib.notify({
            title = 'STOC Hangar',
            description = 'This aircraft was not rented by you.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    DeleteEntity(aircraft)
    rentedAircrafts[plate] = nil

    lib.notify({
        title = 'STOC Hangar',
        description = 'Aircraft stored successfully.',
        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
        icon = 'check',
        iconColor = '#008000'
    })
end

local function OpenHangarMenu()
    if not isOnDuty then
        lib.notify({
            title = 'STOC System',
            description = 'You must be on duty to open hangar.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local playerJob = QBX.PlayerData.job
    if not playerJob or playerJob.name ~= Config.JobName then
        lib.notify({
            title = 'STOC Hangar',
            description = 'You are not a member of the STOC.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local playerRank = playerJob.grade
    if type(playerRank) == 'table' then
        playerRank = playerRank.level or playerRank.grade
    end

    local aircraftOptions = {}
    for _, aircraft in pairs(Config.Aircrafts) do
        if aircraft.rank <= playerRank then
            table.insert(aircraftOptions, {
                title = aircraft.label,
                description = 'Spawn a ' .. aircraft.label,
                onSelect = function()
                    SpawnAircraft(aircraft.model)
                end
            })
        end
    end

    table.insert(aircraftOptions, {
        title = 'Store Aircraft',
        description = 'Return your rented aircraft to the hangar.',
        onSelect = StoreAircraft
    })

    if #aircraftOptions == 0 then
        lib.notify({
            title = 'STOC Hangar',
            description = 'No aircrafts available for your rank.',
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    lib.registerContext({
        id = 'stoc_hangar_menu',
        title = 'STOC Hangar',
        options = aircraftOptions
    })
    lib.showContext('stoc_hangar_menu')
end

exports.ox_target:addSphereZone({
    coords = Config.HangarLocation,
    radius = 1.0,
    options = {
        {
            name = 'open_hangar',
            icon = 'fa-solid fa-plane',
            label = 'Open Hangar',
            distance = 2.5,
            onSelect = function()
                OpenHangarMenu()
            end,
        }
    }
})

local function IsHelipadOccupied(coords)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        if #(vehicleCoords - vector3(coords.x, coords.y, coords.z)) < 5.0 then
            return true
        end
    end
    return false
end

local function SpawnHelicopter(model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        lib.notify({
            title = 'STOC System',
            description = 'Invalid helicopter model.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local spawnCoords = nil
    for _, location in pairs(Config.HeliaircraftsSpawnLocations) do
        if not IsHelipadOccupied(location) then
            spawnCoords = location
            break
        end
    end

    if not spawnCoords then
        lib.notify({
            title = 'STOC System',
            description = 'All helipads are occupied.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    helicopterGarage = CreateVehicle(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    if DoesEntityExist(helicopterGarage) then
        TaskWarpPedIntoVehicle(PlayerPedId(), helicopterGarage, -1)

        local plate = GetVehicleNumberPlateText(helicopterGarage)
        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

        rentedHelicopters[plate] = helicopterGarage

        lib.notify({
            title = 'STOC Helipad',
            description = 'Helicopter spawned and keys added to your inventory.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'check',
            iconColor = '#008000'
        })
    else
        lib.notify({
            title = 'STOC Helipad',
            description = 'Failed to spawn helicopter.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end

    SetModelAsNoLongerNeeded(model)
end

local function StoreHelicopter()
    local plate = GetVehicleNumberPlateText(helicopterGarage)
    local helicopter = rentedHelicopters[plate]
    if not DoesEntityExist(helicopter) then
        lib.notify({
            title = 'STOC Helipad',
            description = 'You don\'t have any aircraft rented .',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local plate = GetVehicleNumberPlateText(helicopter)
    if not rentedHelicopters[plate] then
        lib.notify({
            title = 'STOC Helipad',
            description = 'This aircraft was not rented by you.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    DeleteEntity(helicopter)
    rentedHelicopters[plate] = nil

    lib.notify({
        title = 'STOC Helipad',
        description = 'Aircraft stored successfully.',
        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
        icon = 'check',
        iconColor = '#008000'
    })
end

local function OpenHelipadMenu()
    if not isOnDuty then
        lib.notify({
            title = 'STOC System',
            description = 'You must be on duty to open helipad.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end
    local playerJob = QBX.PlayerData.job
    if not playerJob or playerJob.name ~= Config.JobName then
        lib.notify({
            title = 'STOC System',
            description = 'You are not a member of the STOC.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    local playerRank = playerJob.grade
    if type(playerRank) == 'table' then
        playerRank = playerRank.level or playerRank.grade
    end

    local helicopterOptions = {}
    for _, helicopter in pairs(Config.Heliaircrafts) do
        if helicopter.rank <= playerRank then
            table.insert(helicopterOptions, {
                title = helicopter.label,
                description = 'Spawn a ' .. helicopter.label,
                onSelect = function()
                    SpawnHelicopter(helicopter.model)
                end
            })
        end
    end

    if #helicopterOptions == 0 then
        lib.notify({
            title = 'STOC Helipad',
            description = 'No helicopters available for your rank.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end

    table.insert(helicopterOptions, {
        title = 'Store Helicopter',
        description = 'Return your rented helicopter to the helipad.',
        onSelect = StoreHelicopter
    })

    lib.registerContext({
        id = 'stoc_helipad_menu',
        title = 'STOC Helipad',
        options = helicopterOptions
    })
    lib.showContext('stoc_helipad_menu')
end

exports.ox_target:addSphereZone({
    coords = Config.HelipadLocation,
    radius = 1.0,
    options = {
        {
            name = 'open_helipad',
            icon = 'fa-solid fa-helicopter',
            label = 'Open Helipad',
            distance = 2.5,
            onSelect = function()
                OpenHelipadMenu()
            end,
        }
    }
})

local function OpenElevatorMenu(elevatorName, currentFloor)
    if not isOnDuty then
        lib.notify({
            title = 'STOC System',
            description = 'You must be on duty to use elevator.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end
    local playerJob = QBX.PlayerData.job
    if not playerJob or playerJob.name ~= Config.JobName then
        lib.notify({
            title = 'STOC System',
            description = 'You are not a member of the STOC.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end
    local options = {}
    for index, floor in pairs(Config.Elevators[elevatorName]) do
        if index ~= currentFloor then
            options[#options + 1] = {
                title = floor.floortitle,
                description = floor.label,
                onSelect = function()
                    if HasKeyItem() then
                        UseElevator(floor)
                    else
                        lib.notify({
                            title = 'STOC System',
                            description = 'You don\'t have a access keycard.',
                            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
                            icon = 'ban',
                            iconColor = '#C20E0F'
                        })
                    end
                end
            }
        end
    end

    lib.registerContext({
        id = 'elevator_menu',
        title = elevatorName,
        options = options,
        position = 'top-right'
    })
    lib.showContext('elevator_menu')
end

function UseElevator(floor)
    local ped = PlayerPedId()

    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(ped, floor.coords.x, floor.coords.y, floor.coords.z)
    SetEntityHeading(ped, floor.heading)
    Wait(100)

    lib.progressBar({
        duration = Config.JourneyTime,
        label = 'Travelling...',
        useWhileDead = false,
        canCancel = false
    })

    DoScreenFadeIn(1500)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, 'doorbell', 0.2)
    lib.notify({
        title = 'Elevator',
        description = 'You have arrived at ' .. floor.floortitle,
        type = 'success'
    })
end

function HasKeyItem()
    local itemCount = exports.ox_inventory:Search('count', Config.KeyItem)
    return itemCount > 0
end

CreateThread(function()
    for elevatorName, elevatorFloors in pairs(Config.Elevators) do
        for index, floor in pairs(elevatorFloors) do
            exports.ox_target:addBoxZone({
                coords = vec3(floor.coords.x, floor.coords.y, floor.coords.z),
                size = vec3(3, 3, 3),
                rotation = floor.heading,
                options = {
                    {
                        name = elevatorName .. '_' .. index,
                        icon = 'fas fa-elevator',
                        label = 'Use Elevator',
                        onSelect = function()
                            OpenElevatorMenu(elevatorName, index)
                        end
                    }
                }
            })
        end
    end
end)

exports.ox_target:addGlobalPlayer({
    {
        name = 'search_player',
        icon = 'fas fa-magnifying-glass',
        label = 'Search Citizen',
        distance = 2.0,
        onSelect = function(data)
            TriggerEvent('stoc:client:SearchPlayer')
        end
    },
})

local function getClosestPlayer(distance)
    local coords = GetEntityCoords(cache.ped)
    local player, playerPed = lib.getClosestPlayer(coords, distance or 2.5)
    if not player then 
        return 
        lib.notify({
            title = 'STOC System',
            description = 'No one nearby!',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
    end

    return player, playerPed
end

RegisterNetEvent('stoc:client:SearchPlayer', function()
    if not isOnDuty then
        lib.notify({
            title = 'STOC Equipment',
            description = 'You must be on duty to do a search.',
            style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
            icon = 'ban',
            iconColor = '#C20E0F'
        })
        return
    end
    local player = getClosestPlayer()
    if not player then return end
    local playerId = GetPlayerServerId(player)
    exports.ox_inventory:openNearbyInventory()
    TriggerServerEvent('stoc:server:SearchPlayer', playerId)
end)

RegisterNetEvent('stoc:panicBlip')
AddEventHandler('stoc:panicBlip', function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.5)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Panic Button Location')
    EndTextCommandSetBlipName(blip)

    SetTimeout(60000, function()
        RemoveBlip(blip)
    end)
end)

RegisterNetEvent('stoc:panicDuty', function(isOnDuty)
    if QBX.PlayerData.job.name == 'stoc' and isOnDuty then
        exports.ox_lib:addRadialItem({
            id = 'stocPanic',
            label = 'Emergency Button',
            icon = 'bell',
            onSelect = function()
                TriggerServerEvent('stoc:panicButton')
            end
        })
    else
        exports.ox_lib:removeRadialItem('stocPanic')
    end
end)

