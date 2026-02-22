fx_version 'cerulean'
game 'gta5'

description 'DjonStNix Shops - Premium V5 Overhaul'
author 'DjonLuc'
version '5.0.0'

shared_scripts {
    'config.lua',
    'shared/bridge/index.lua',
    'shared.lua'
}

ui_page 'ui/index.html'

files {
    'ui/**'
}

client_scripts {
    'client/main.lua',
    'client/npc.lua',
    'client/blips.lua',
    'client/nui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/economy.lua',
    -- 'server/franchise.lua', -- DISABLED: Re-enable when franchise system is ready
    'server/main.lua'
}

dependencies {
    'qb-core',
    'PolyZone',
    'qb-target',
    'qb-menu',
    'qb-input',
    'oxmysql'
}
