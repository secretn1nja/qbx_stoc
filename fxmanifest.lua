fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'n1nja'
description 'STOC Faction Job for QBX Core'
version '1.1.0'

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

shared_scripts {
    "@qbx_core/modules/playerdata.lua",
    '@ox_lib/init.lua',
    'config.lua',
}
