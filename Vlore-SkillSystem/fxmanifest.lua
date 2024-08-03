fx_version 'cerulean'
game 'gta5'

author 'VGroup'
description 'Skrypt na ofce'
version '1.0.0'
lua54 'yes'


client_scripts {
    'config.lua',
	'client/*.lua'
} 

server_scripts {
    'config.lua',
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}