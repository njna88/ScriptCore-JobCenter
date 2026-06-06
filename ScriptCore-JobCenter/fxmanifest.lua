fx_version 'cerulean'
game 'gta5'

name 'ScriptCore-JobCenter'
author 'ScriptCore.dk'
description 'Clean dark JobCenter with NPC, ox_target and NUI'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
