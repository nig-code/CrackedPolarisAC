fx_version 'bodacious'
game 'gta5'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "configs/clientconfig.lua",
    "configs/serverconfig.lua",
    "server.lua",
    "Gbans.json",
}

client_scripts {
    "configs/clientconfig.lua",
    "client.lua",
    "Detections.lua",
}