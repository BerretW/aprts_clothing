fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
version '3.30.0'
-- shared_script {
--     'shared/*', 
-- }
client_scripts {
	'shared/*',
	'client/**/*',
}


server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'shared/*',
	'server/**/*',
	-- 'server/*',
}

files {
	'ui/**/*',
	'ui/*',
	'ui/lang.js',
}

escrow_ignore {
	'shared/*.lua',
	'client/adapters/*.lua',
	'client/*.lua',
	'server/adapters/*.lua',
	'server/*.lua',
}

ui_page 'ui/index.html'

lua54 'yes'
dependency '/assetpacks'