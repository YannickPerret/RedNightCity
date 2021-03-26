-- VARIABLE CUSTOM

settings = {}
settings.defaultSettings = {
	['startingCash'] = GetConvar('startingCash', '0'),
	['startingBank'] = GetConvar('startingBank', '0'),
    ['defaultDatabase'] = GetConvar('defaultDatabase', '1'),
    ['enableCustomData'] = GetConvar('enableCustomData', '0'),
    ['identifierUsed'] = GetConvar('identifierUsed', 'steam'),
    ['commandDelimeter'] = GetConvar('commandDelimeter', '/')
}

Users = {}





RegisterServerEvent("playerActivated")


-- FUNCTION CUSTOM 
function printServer(message)
    print(client_prefix .. message)
end

--Etape 3 
function loadUser(identifier, source, new, licenseNotRequired)
	local Source = source
	db.retrieveUser(identifier, function(user, isJson)
		-- J'ai récupéré si vrais :toutes les données de l'utilisateur , si faux : false | valeur au format tableau

		if isJson then -- test pour être sur que j'ai toutes les données
			user = json.decode(user)
		end
		
		if user.license or licenseNotRequired then
			-- Creates the player class for OOP imitation and then sets a var to say which idType was used (This isn't relevant anymore)


			Users[Source] = CreatePlayer(source, user.permission_level, user.money, user.bank, user.identifier, user.license, user.group, user.roles or "")

			--Users[Source].setSessionVar('idType', 'identifier')
			
			-- Tells other resources that a player has loaded
			TriggerEvent('playerLoaded', Source, Users[Source])
			
			-- Sets a decorator on the client if enabled, allows some cool stuff on the client see: https://runtime.fivem.net/doc/natives/#_0xA06C969B02A97298
					--if(settings.defaultSettings.enableRankDecorators ~= "false")then
					--	TriggerClientEvent('redem:setPlayerDecorator', Source, 'rank', Users[Source]:getPermissions())
					--end

							-- Sets the money "icon" on the client. This is UTF8
					--TriggerClientEvent('redem:setMoneyIcon', Source,settings.defaultSettings.moneyIcon)

							-- Give client data
					--TriggerClientEvent('redem:playerLoaded', Source, Users[Source].getMoney())

			-- Sends the command suggestions to the client, this creates a neat autocomplete
			--[[for k,v in pairs(commandSuggestions) do
				TriggerClientEvent('chat:addSuggestion', Source, settings.defaultSettings.commandDelimeter .. k, v.help, v.params)
			end]]

			-- If a player connected that was never on the server before then this will be triggered for other resources
			if new then
				TriggerEvent('newPlayerLoaded', Source, Users[Source])
            end
		else
			-- Irrelevant
			local license

			for k,v in ipairs(GetPlayerIdentifiers(Source))do
				if string.sub(v, 1, string.len("license:")) == "license:" then
					license = v
					break
				end
			end

			if license then
				MySQL.Async.execute('UPDATE players SET `monney` = @amount WHERE license = @identifiers',{['identifiers'] = identifiers[1], ['amount'] = amount},function()end)
				--db.updateUser(user.identifier, {license = license}, function()
					loadUser(user.identifier, Source, false)
				
			else
				loadUser(user.identifier, Source, false, true)
			end
		end
	end)
end


-- Etape 2
function registerUser(identifier, source)
	local Source = source
	db.doesUserExist(identifier, function(exists)
		if exists then
			loadUser(identifier, Source, false)
		else
			local license = "license:rockstardevlicense"
			--[[for k,v in ipairs(GetPlayerIdentifiers(Source))do
				if string.sub(v, 1, string.len("license:")) == "license:" then
					license = v
					break
				end
			end]]

			db.createUser(identifier, license, function()
				loadUser(identifier, Source, true)
			end)
		end
	end)
end





-- Etape 1
AddEventHandler("playerActivated", function()
    local _source = source
    printServer("Nouveau joueur connecté :" .. GetPlayerName(_source))

    local id

    for k,v in ipairs(GetPlayerIdentifiers(_source))do
        if string.sub(v, 1, string.len(settings.defaultSettings.identifierUsed .. ":")) == (settings.defaultSettings.identifierUsed .. ":") then
            id = v
            break
        end
    end
        
    registerUser(id, _source) -- SteamId + source
end)