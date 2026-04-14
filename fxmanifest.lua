fx_version 'cerulean'
lua54 'yes'
game 'gta5'

description 'mri Qbox - Jobs and Gangs System'
credits 'Polisek'
ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'BRIDGE/config.lua',
    'config.lua',
    'secure.lua',
    'client/utilities.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'BRIDGE/client/inventory.lua',
    'BRIDGE/client/target.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'BRIDGE/server/framework.lua',
    'BRIDGE/server/inventory.lua',
    'server/db.lua',
    'server/server.lua',
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql',
    'mri_Qbox'
}

files {
    'locales/*.json'
}
