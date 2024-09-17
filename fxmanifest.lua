fx_version 'cerulean'
game 'gta5'
name 'sf_camerasecurity'
author 'Soufiane'
lua54 'yes'
description 'Advanced Camera security script'
version '1.5.4'

ui_page 'html/index.html'
files {'html/index.html', 'html/vue.min.js', 'html/script.js', 'html/vcr-ocd.ttf', 'html/images/*.*'}

shared_scripts {'@ox_lib/init.lua', 'shared/functions.lua', 'config.lua'}
client_scripts {'bridge/**/client.lua', 'client/*.lua'} 
server_scripts {'@oxmysql/lib/MySQL.lua', 'bridge/**/server.lua', 'server/*.lua'}

dependencies {'oxmysql', 'ox_lib'}
