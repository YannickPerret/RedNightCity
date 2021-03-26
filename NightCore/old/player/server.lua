-- VARIABLE DECLARER 
_firstCheckPerformed = false

local playerCoords = {}
local DBData

Users = {}

tusers = {}
tusers.identifier = nil



-- REGISTER EVENT
RegisterServerEvent("selectCharacter")

RegisterServerEvent("createCharacter")

RegisterServerEvent("registerCoords")


-- FUNCTION Custom

function loadCharacter(_source, user, charid)
	TriggerEvent("retrieveUser", user.getIdentifier(), charid, function(_user)
		if _user ~= false then
			local rpPlayer = CreateRoleplayPlayer(_source, _user.identifier, _user.name, _user.money, _user.gold, _user.license, _user.group, _user.firstname, _user.lastname, _user.xp, _user.level, _user.job, _user.jobgrade)
			Users[_source] = rpPlayer

			for k,v in pairs(user) do Users[_source][k] = v end

			-- Set character related stuff
			Users[_source].setMoney(_user.money)
			Users[_source].setSessionVar("charid", charid)

			TriggerEvent('playerLoaded', _source, Users[_source]) -- TO OTHER RESOURCES
			TriggerClientEvent('moneyLoaded', _source, Users[_source].getMoney())
			TriggerClientEvent('goldLoaded', _source, Users[_source].getGold())
			TriggerClientEvent('xpLoaded', _source, Users[_source].getXP())
			TriggerClientEvent('levelLoaded', _source, Users[_source].getLevel())
			TriggerClientEvent('showID', _source, _source)
		else
			print("That character does not exist!")
		end
	end)
end

function addCharacter(_source, user, firstname, lastname)
	if(firstname and lastname)then
		TriggerEvent("createUser", user.getIdentifier(), firstname, lastname, function(charID)
			print("Character made!")
			loadCharacter(_source, user, charID)
		end)
	end
end





-- EVENT CUSTOM


AddEventHandler('retrieveUser', function(identifier, charid, callback)
	local SavedCallback = callback
	MySQL.Async.fetchAll('SELECT * FROM characters WHERE `identifier`=@identifier AND `characterid`=@characterid;', {identifier = identifier, characterid = charid}, function(users)
		if users[1] then
			SavedCallback(users[1])
		else
			SavedCallback(false)
		end
	end)
end)



AddEventHandler('createUser', function(identifier, firstname, lastname, callback)
	MySQL.Async.fetchAll('SELECT * FROM characters WHERE `identifier`=@identifier', {identifier = identifier}, function(users)
		DBData = users
		local charID = 1
		while CharacterExist(charID) do 
		   charID = charID + 1
      		 end
		print("Found charID "..charID)
		MySQL.Async.execute('INSERT INTO characters (`identifier`, `firstname`, `lastname`, `characterid`) VALUES (@identifier, @firstname, @lastname, @characterid);',
		{
			identifier = identifier,
			firstname = firstname,
			lastname = lastname,
			characterid = charID
			
		}, function(rowsChanged)
			callback(charID)
		end)
	end)
end)

AddEventHandler('doesUserExist', function(identifier, cb)
    MySQL.Async.fetchAll('SELECT 1 FROM users WHERE `identifier`=@identifier;', {identifier = identifier}, function(users)
        if users[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)



AddEventHandler("registerCoords", function(coords)
    playerCoords[source] = coords
end)



AddEventHandler("selectCharacter", function(character)
	local _source = source
	TriggerEvent("getPlayerFromId", _source, function(user)
		--loadCharacter(_source, user, character)
	end)	
end)


AddEventHandler("createCharacter", function(firstname, lastname)
	local _source = source
	TriggerEvent("getPlayerFromId", _source, function(user)
		addCharacter(_source, user, firstname, lastname)
	end)
end)



AddEventHandler("getPlayerFromId", function(user, cb)
	if(Users)then
		if(Users[user])then
			cb(Users[user])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)




AddEventHandler("getAllPlayers", function(cb)
	cb(Users)
end)

function getPlayerFromId(id)
	return Users[id]
end
