Config = {}

-- Job name for STOC
Config.JobName = 'stoc'
Config.KeyItem = 'access_keycard'

-- Duty location
Config.DutyLocation = vec3(-2346.8, 3268.38, 32.81) 

-- Equipment configuration
Config.EquipmentLocation = vec3(-2358.29, 3255.25, 32.81) 
Config.Equipment = {
    primaryWeapon = 'WEAPON_CARBINERIFLE',
    secondaryWeapon = 'WEAPON_PISTOL',
    armor = 'armour',
    items = {
        { name = 'bandage',    count = 5 },
        { name = 'ammo-rifle', count = 120 },
        { name = 'ammo-9', count = 45 },
        { name = 'handcuffs',     count = 1 },
    }
}

-- Stress reduction configuration
Config.ReduceStressOnShoot = true -- Enable/disable stress reduction

-- Garage configuration
Config.GarageLocation = vec3(-2343.69, 3262.78, 32.83) 
Config.VehicleSpawnLocation = vec4(-2335.18, 3258.49, 32.83, 327.44) 
Config.Vehicles = {
    { model = 'fbi',  label = 'Patrol Car', rank = 1 },
    { model = 'fbi2', label = 'SUV',        rank = 2 },
    { model = 'insurgent2',    label = 'Riot Van',   rank = 3 }
}

-- Hangar configuration
Config.HangarLocation = vec3(-2172.76, 3255.93, 32.81) 
Config.AircraftSpawnLocation = vec4(-1827.57, 2974.77, 32.81, 57.94) 
Config.Aircrafts = {
    { model = 'lazer',  label = 'Lazer', rank = 1 },
    { model = 'Titan', label = 'Titan',        rank = 2 },
}

-- Helipad configuraion
Config.HelipadLocation = vec3(-2172.76, 3255.93, 32.81) 
Config.HeliaircraftsSpawnLocations = {
    vec4(-2055.86, 3098.46, 32.81, 328.95),            
    vec4(-1990.5, 3061.49, 32.81, 330.51),              
    vec4(-1925.28, 3024.61, 32.81, 332.49)              
}
Config.Heliaircrafts = {
    { model = 'buzzard2', label = 'Buzzard', rank = 3 },
    { model = 'maverick', label = 'Maverick', rank = 4 },
}

-- Callsign location
Config.CallSignLocation = vec3(-2356.74, 3244.25, 92.9) 

-- Elevator configuration
Config.JourneyTime = 2000 -- 1000 is 1 second
Config.Elevators = {
    ['STCO Base'] = {
        {
            floortitle = 'Surface',
            label = 'Access the surface.',
            coords = vec3(-2052.07, 3237.51, 31.5),
            heading = 87.83,
        },
        {
            floortitle = 'Level -8',
            label = 'Access the Storage Core.',
            coords = vec3(-2052.97, 3236.64, -0.5),
            heading = 91.48,
        },
        {
            floortitle = 'Level -9',
            label = 'Access the Storage Base.',
            coords = vec3(-2055.43, 3237.56, -5.51),
            heading = 91.48,
        },
        {
            floortitle = 'Level -12',
            label = 'Access the Facility Core.',
            coords = vec3(-2052.31, 3237.45, -16.49),
            heading = 91.48,
        },
        {
            floortitle = 'Level -18',
            label = 'Access the Facility Labs.',
            coords = vec3(-1776.29, 3165.9, -46.56),
            heading = 91.48,
        }
    }
}

-- EmergencyButton configuration
Config.PanicEnabled = true
Config.PanicButtonDuration = 15000
