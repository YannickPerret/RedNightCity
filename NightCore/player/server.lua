-- VARIABLE CUSTOM

settings = {}
settings.defaultSettings = {
	['startingCash'] = GetConvar('startingCash', '100'),
	['startingBank'] = GetConvar('startingBank', '100'),
    ['defaultDatabase'] = GetConvar('defaultDatabase', '0'),
    ['enableCustomData'] = GetConvar('enableCustomData', '0'),
    ['identifierUsed'] = GetConvar('identifierUsed', 'steam'),
    ['commandDelimeter'] = GetConvar('commandDelimeter', '/')
}

Users = {}

RegisterServerEvent("playerActivated")

RegisterServerEvent("SaveCoordsPlayer")



-- FUNCTION CUSTOM 
function printServer(message)
    print(server_prefix .. message)
end

-- Fonction pour sauvegarder la monney + bank de tous les joueurs toutes les 60 secondes

local function saveAllPlayerMoney()
	SetTimeout(60000, function() 
		Citizen.CreateThread(function()
			for k,v in pairs(Users)do
				if Users[k] ~= nil then
					MySQL.Async.execute('UPDATE players SET `money` = @money, bank = @bank WHERE identifier = @identifiers',{['identifiers'] = v.get('identifier'), ['money'] = v.getMoney(), ['bank'] = v.getBank()},function(result)
						if(result) then
							printServer("^2OK^7 Joueur "..v.get('identifier')..' argent/Bank sauvegardé')
						else
							printServer("^1ERROR^7 Joueur "..v.get('identifier')..' argent/Bank non sauvegardé')						
						end
					end)
				end
			end

			saveAllPlayerMoney()
		end)
	end)
end
saveAllPlayerMoney()


function savePlayerMoney()
	local Source = source
	local identifier = GetPlayerIdentifiers(source)
	print(Users[Source].getMoney())
	print(Users[Source].getBank())

	MySQL.Async.execute('UPDATE players SET `money` = @money, bank = @bank WHERE identifier = @identifiers',{['identifiers'] = identifier[1], ['money'] = Users[Source].getMoney(), ['bank'] = Users[Source].getBank()},function(result)
		if(result) then
			printServer("^2OK^7 Joueur "..identifier[1]..' argent/Bank sauvegardé')
		else
			printServer("^1ERROR^7 Joueur "..identifier[1]..' argent/Bank non sauvegardé')						
		end
	end)
end

--[[function savePlayerMoney(source)
	player2 = nil
	Citizen.CreateThread(function()
		for k,v in pairs(Users)do
			if Users[k] ~= nil then
				print(Users[k].identifier)
				if Users[k] == player1 or player2 then
					if Users[k] == player1 then
						MySQL.Async.execute('UPDATE players SET `money` = @money, bank = @bank WHERE identifier = @identifiers',{['identifiers'] = v.get('identifier'), ['money'] = v.getMoney(), ['bank'] = v.getBank()},function(result)
							if(result) then
								printServer("^2OK^7 Joueur "..v.get('identifier')..' argent/Bank sauvegardé')
							else
								printServer("^1ERROR^7 Joueur "..v.get('identifier')..' argent/Bank non sauvegardé')						
							end
						end)
					elseif Users[k] == player2 then
						MySQL.Async.execute('UPDATE players SET `money` = @money, bank = @bank WHERE identifier = @identifiers',{['identifiers'] = v.get('identifier'), ['money'] = v.getMoney(), ['bank'] = v.getBank()},function(result)
							if(result) then
								printServer("^2OK^7 Joueur "..v.get('identifier')..' argent/Bank sauvegardé')
							else
								printServer("^1ERROR^7 Joueur "..v.get('identifier')..' argent/Bank non sauvegardé')						
							end
						end)
					end
				end
			end
		end
	end)
end]]


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
			Users[Source] = CreatePlayer(source, user.permission_level, user.money, user.bank, user.identifier, user.license, user.coords, user.group, user.roles or "")

							-- Sets the money "icon" on the client. This is UTF8
			TriggerClientEvent('setMoneyIcon', Source,settings.defaultSettings.moneyIcon)

							-- Give client data
			TriggerClientEvent('playerLoaded', Source, Users[Source].getMoney())

			TriggerClientEvent('SetCoordsPlayer', Source, Users[Source].getCoords())
			-- Sends the command suggestions to the client, this creates a neat autocomplete
			--[[for k,v in pairs(commandSuggestions) do
				TriggerClientEvent('chat:addSuggestion', Source, settings.defaultSettings.commandDelimeter .. k, v.help, v.params)
			end]]

			-- If a player connected that was never on the server before then this will be triggered for other resources
			if new then
				TriggerEvent('newPlayerLoaded', Source, Users[Source])
				printServer("^2OK ^7Nouveau joueur créer : ".. GetPlayerName(source))
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
				MySQL.Async.execute('UPDATE players SET `license` = @license WHERE identifier = @identifiers',{['identifiers'] = identifiers[1], ['license'] = license},function()end)
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
			--local license = "license:rockstardevlicense"
			for k,v in ipairs(GetPlayerIdentifiers(Source))do
				if string.sub(v, 1, string.len("license:")) == "license:" then
					license = v
					break
				end
			end
			db.createUser(identifier, license, function()
				loadUser(identifier, Source, true)
			end)
		end
	end)
end

-- Etape 1
AddEventHandler("playerActivated", function()
    local _source = source
    printServer("Nouveau joueur connecté " .. GetPlayerName(_source))

    local id

    for k,v in ipairs(GetPlayerIdentifiers(_source))do
        if string.sub(v, 1, string.len(settings.defaultSettings.identifierUsed .. ":")) == (settings.defaultSettings.identifierUsed .. ":") then
            id = v
            break
        end
    end
    registerUser(id, _source) -- SteamId + source
end)



-- Sauvegarder toutes les 15 minutes via le client la position du joueur. AJOUTER DES NOTIFICATIONS
AddEventHandler("SaveCoordsPlayer", function(heading, coords) --A refaire comme pour la sauvegarde de l'argent
	local source = source
	identifier = GetPlayerIdentifiers(source)
	MySQL.Async.execute('UPDATE players SET `coords` = @coords WHERE identifier = @identifiers',{['identifiers'] = identifier[1], ['coords'] = coords},function(result)
		if(result) then 
			printServer("^2OK ^7Sauvegarde du client "..GetPlayerName(source))
		else

		end
	end)
end)


RegisterNetEvent("updateMoney")
AddEventHandler("updateMoney", function(money, transaction)
	local source = source
	if (money ~= nil) then
		if(transaction) then
		Users[source].addMoney(money)
		else
			Users[source].removeMoney(money)
		end
	end

end)

RegisterServerEvent("")

-- Allow other resources to set raw data on a player instead of using helper functions, these aren't really used often.
AddEventHandler("setPlayerData", function(user, k, v, cb)
	if(Users[user])then
		if(Users[user].get(k))then
			if(k ~= "money") then
				Users[user].set(k, v)

				db.updateUser(Users[user].get('identifier'), {[k] = v}, function(d)
					if d == true then
						cb("Player data edited", true)
					else
						cb(d, false)
					end
				end)
			end

			if(k == "group")then
				Users[user].set(k, v)
			end
		else
			cb("Column does not exist!", false)
		end
	else
		cb("User could not be found!", false)
	end
end)



AddEventHandler("getPlayerFromIdentifier", function(identifier, cb)
	db.retrieveUser(identifier, function(user)
		cb(user)
	end)
end)


