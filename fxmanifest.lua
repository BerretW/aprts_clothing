fx_version 'cerulean'
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'SpoiledMouse'
version '1.1'
description 'aprts_clothing refactored'

games {"rdr3"}

shared_scripts {
        '@jo_libs/init.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'data/*.lua' -- Načte všechny soubory ve složce data
}

client_scripts {
    'client/utils.lua',    -- Pomocné funkce první
    'client/camera.lua',   -- Kamera
    'client/clothing.lua', -- Logika oblečení
    'client/overlay.lua',
    'client/menu.lua',     -- Logika menu
    'client/main.lua',     -- Hlavní smyčky a init
    'client/nui.lua',      -- NUI callbacky
    'client/commands.lua', -- Příkazy
}

server_scripts {
    'server/database.lua', -- Databáze první
    'server/main.lua',
    'server/events.lua',
    'server/commands.lua',
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/fonts/*.ttf',
    'nui/img/*.png'
}
jo_libs {
  'component',
  'pedTexture',
}