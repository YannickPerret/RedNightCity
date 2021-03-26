db = {}

--Savooir si l'utilisateur existe en bdd
function db.doesUserExist(identifier, callback)
	MySQL.Async.fetchAll('SELECT * FROM players WHERE identifier=@identifier', {identifier = identifier}, function(users)
		if users[1] then
			callback(users[1])
		else
			callback(false)
		end
	end)
end

--Create de l'utilisateur en BDD. Attention par la suite faire avec un choix multi-characters
function db.createUser(identifier, license, callback)
	--[[MySQL.Async.fetchAll('SELECT * FROM characters WHERE `identifier`=@identifier', {identifier = identifier}, function(users)
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
	end)]]--

	MySQL.Async.execute('INSERT INTO players(identifier, license, money, bank, permission_level, roles, `group`) VALUES (@identifier, @license, @money, @bank, @permission_level, @roles, @group)',
		{
			identifier = identifier,
            license = license,
            bank = settings.defaultSettings.startingCash,
            money = settings.defaultSettings.startingBank,
			permission_level = permission_level,
          	roles = 0,
			group = "",
		}, function(rowsChanged)
			callback()
	end)


end

function db.retrieveUser(identifier, callback)
	local SavedCallback = callback
	MySQL.Async.fetchAll('SELECT * FROM players WHERE `identifier`=@identifier', {identifier = identifier}, function(users)
		if users[1] then
			SavedCallback(users[1])
		else
			SavedCallback(false)
		end
	end)

end

--db.updateUser(self.identifier, {roles = table.concat(self.roles, "|")}, function()end)