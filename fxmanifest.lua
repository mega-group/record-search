fx_version 'cerulean'
game 'gta5'

author 'Mega Utilities\' Mega Group'
description 'Search your database for FivePD Records'
version '1.0.0'

client_scripts  {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/updater.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/main.js'
}

dependencies {
    'oxmysql',
    'fivepd'
}
