fx_version 'cerulean'
game 'gta5'
lua54 'true'

name 'Fearx-antirob'
description 'Anti-rob system for ox_inventory (ESX & QB-Core)'
author 'Fearx'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'ox_inventory',
    'ox_lib'
}