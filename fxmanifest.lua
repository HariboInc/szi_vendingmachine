fx_version 'cerulean'
game 'gta5'

author 'Sub-Zero Interactive'
description 'This is a script that allows you to rob vending machines using fivem-target or bt-target.'
version '1.0'

server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/client.lua'
}

dependencies {
    'es_extended',
    'mhacking',
    'mythic_progbar',
    'mythic_notify',
}