fx_version 'cerulean'
lua54 'yes'
game 'gta5'

description 'mri Qbox - Jobs and Gangs System'
credits 'Polisek'
ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/bridge.lua',
    'shared/config.lua',
    'shared/secure.lua',
    'shared/utilities.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/bridge/inventory.lua',
    'client/bridge/target.lua',
    'client/main.lua',
    'client/creator.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge/framework.lua',
    'server/bridge/inventory.lua',
    'server/db.lua',
    'server/main.lua',
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
    'locales/*.json',
    'server/data/*.json'
}
