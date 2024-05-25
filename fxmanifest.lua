fx_version 'cerulean'
game 'gta5'
name 'sf_camerasecurity'
author 'Soufiane'
lua54 'yes'
description 'Advanced Camera security script'
version '1.0.5'

ui_page 'html/index.html'
files { 'html/index.html', 'html/vue.min.js', 'html/script.js', 'html/vcr-ocd.ttf'}

shared_scripts {'@ox_lib/init.lua', 'config.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua', 'server.lua'}
client_script 'client.lua'

dependencies {
	'oxmysql',
	'ox_lib',
	'qb-core'
}

