fx_version "adamant"
games {"rdr3"}
version '0.0.1'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/h.html'

client_scripts {
	'config.lua',
	'player/client.lua',

	'system/client.lua',

	'activity/piano/piano.lua',
	'ragdoll/client.lua',

	'admin/client.lua',
	'notification//client.lua',	
}

files {
    'notification/html/h.html',
	'notification/html/style.css',
	'notification/html/crock.ttf',
}


server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',

	'player/server_DB.lua',
	'player/server_class_user.lua',
	'player/server.lua',

	'system/server.lua',
}

client_scripts{

	'ShowTooltip',
	'GetGroundZ',
}

server_exports {
	'getPlayerFromId',
}

export "GetGroundZ"
export "startUI"
export "closeUI"