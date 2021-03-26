function CreatePlayer(source, permission_level, money, bank, identifier, license, coords, group, roles)
	local self = {}

	-- Initialize all initial variables for a user
	self.source = source
	self.permission_level = permission_level
	self.money = money
	self.bank = bank
	self.identifier = identifier
	self.license = license
	self.coords = coords
	self.group = group
	self.session = {}
	self.roles = stringsplit(roles, "|")


	--ExecuteCommand('add_principal identifier.' .. self.identifier .. " group." .. self.group)
	local rTable = {}


	-- Sets money for the user
	rTable.setMoney = function(m)
		if type(m) == "number" then
			local prevMoney = self.money
			local newMoney = m

			self.money = m
			
			-- Performs some math to see if money was added or removed, mainly for the UI component
			if((prevMoney - newMoney) < 0)then
				TriggerClientEvent("addedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
			else
				TriggerClientEvent("removedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
			end
			TriggerClientEvent('addMoney', self.money, m)


			TriggerClientEvent('activateMoney', self.source , self.money)
		else
			print('ES_ERROR: There seems to be an issue while setting money, something else then a number was entered.')
		end
	end




	-- Adds money to the user
	rTable.addMoney = function(m)
		if type(m) == "number" then
			local prevMoney = self.money
			local newMoney = m
			print("prevmoney : "..prevMoney.." et NewMonney : "..newMoney)
			-- Performs some math to see if money was added or removed, mainly for the UI component
			if((prevMoney + newMoney) < 0)then
				TriggerClientEvent("sendNotification", "^1ERROR ^7Vous n'avez pas les fonds pour cette transaction")
			else
				local newMoney = self.money + m
				self.money = newMoney

				TriggerClientEvent("addedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
				TriggerClientEvent('addMoney', self.source, self.money)
				savePlayerMoney(self.source)
				
				TriggerClientEvent("sendNotification", "^2OK ^7 Vous avez reçu $"..m)
			end
		else
			log('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
			print('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
		end
	end

	-- Adds money to the user
	rTable.removeMoney = function(m)
		if type(m) == "number" then
			local prevMoney = self.money
			local newMoney = m
			-- Performs some math to see if money was added or removed, mainly for the UI component
			if((prevMoney - newMoney) < 0)then
				TriggerClientEvent("sendNotification", "^1ERROR ^7Vous n'avez pas les fonds pour cette transaction")
			else
				local newMoney = self.money - m
				self.money = newMoney
				TriggerClientEvent("addedMoney", self.source, math.abs(prevMoney - newMoney), (settings.defaultSettings.nativeMoneySystem == "1"))
				
				TriggerClientEvent('addMoney', self.source, self.money)

				savePlayerMoney(self.source)

				TriggerClientEvent("sendNotification", "^2OK ^7 Vous avez reçu $"..m)
			end
		else
			log('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
			print('ES_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
		end
	end


	-- Returns money for the player
	rTable.getMoney = function()
		return self.money
	end

	-- Return Bank for the player 
	rTable.getBank = function()
		return self.bank
	end

	-- Returns Coords for the player
	rTable.getCoords = function()
		return self.coords
	end
	 
	-- Session variables, handy for temporary variables attached to a player
	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end


	-- Global set
	rTable.set = function(k, v)
		self[k] = v
	end

	-- Global get
	rTable.get = function(k)
		return self[k]
	end

	-- Creates globals, pretty nifty function take a look at https://docs.essentialmode.com for more info
	rTable.setGlobal = function(g, default)
		self[g] = default or ""

		rTable["get" .. g:gsub("^%l", string.upper)] = function()
			return self[g]
		end

		rTable["set" .. g:gsub("^%l", string.upper)] = function(e)
			self[g] = e
		end

		Users[self.source] = rTable
	end


	return rTable
end







function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end