function CreateRoleplayPlayer(source, identifier, name, money, gold, license, group, firstname, lastname, job, jobgrade)
	local self = {}

	self.source = source
	self.gold = gold
	self.group = group
	self.firstname = firstname
	self.lastname = lastname
	self.job = job
	self.jobgrade = jobgrade

	
	local rTable = {}

	rTable.setFirstname = function(m)
		if type(m) == "string" then
			TriggerEvent("setPlayerData", self.source, "firstname", m, function(response, success)
				self.firstname = m
			end)
		else
			print('REDEMRP_ERROR: There seems to be an issue while setting firstname, something else then a text was entered.')
		end
	end
	
	rTable.setLastname = function(m)
		if type(m) == "string" then
			TriggerEvent("setPlayerData", self.source, "lastname", m, function(response, success)
				self.lastname = m
			end)
		else
			print('REDEMRP_ERROR: There seems to be an issue while setting lastname, something else then a text was entered.')
		end
	end

	rTable.setJob = function(m)
		if type(m) == "string" then
			--TriggerEvent("setPlayerData", self.source, "job", m, function(response, success)
				self.job = m
			--end)
		else
			print('REDEMRP_ERROR: There seems to be an issue while setting job, something else then a text was entered.')
		end
	end

	rTable.setJobgrade = function(m)
		if type(m) == "number" then
			--TriggerEvent("setPlayerData", self.source, "jobgrade", m, function(response, success)
				self.jobgrade = m
			--end)
		else
			print('REDEMRP_ERROR: There seems to be an issue while setting jobgrade, something else then a text was entered.')
		end
	end
	
	
	-- Sets a players gold balance
	rTable.setGold = function(m)
		if type(m) == "number" then
				self.gold = m

			TriggerClientEvent('addGold', self.source, self.gold)
			TriggerClientEvent('activateGold', self.source , self.gold)
		else
			print('REDEMRP_ERROR: There seems to be an issue while setting gold, something else then a number was entered.')
		end
	end

	rTable.getGold = function()
		return self.gold
	end

	-- Kicks the player with the specified reason
	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	rTable.addMoney = function(m)
		if type(m) == "number" then
			local newMoney = self.money + m

			self.money = newMoney
			
	

			TriggerClientEvent('addMoney', self.source, m)
			TriggerClientEvent('activateMoney', self.source , self.money)
		else
			print('REDEMRP_ERROR: There seems to be an issue while adding money, a different type then number was trying to be added.')
		end
	end

	-- Removes money from the user
	rTable.removeMoney = function(m)
		if type(m) == "number" then
			local newMoney = self.money - m

			self.money = newMoney

			TriggerClientEvent('removeMoney', self.source, m)
			TriggerClientEvent('activateMoney', self.source , self.money)
		else
			print('REDEMRP_ERROR: There seems to be an issue while removing money, a different type then number was trying to be removed.')
		end
	end

	-- Adds money to a users gold
	rTable.addGold = function(m)
		if type(m) == "number" then
			local newGold = self.gold + m
			self.gold = newGold

			TriggerClientEvent('addGold', self.source, m)
			TriggerClientEvent('activateGold', self.source , self.gold)
		else
			print('REDEMRP_ERROR: There seems to be an issue while adding to gold, a different type then number was trying to be added.')
		end
	end

	-- Removes money from a users gold
	rTable.removeGold = function(m)
		if type(m) == "number" then
			local newGold = self.gold - m
			self.gold = newGold
			
			TriggerClientEvent('removeGold', self.source, m)
			TriggerClientEvent('activateGold', self.source , self.gold)
		else
			print('REDEMRP_ERROR: There seems to be an issue while removing from gold, a different type then number was trying to be removed.')
		end
	end
	
	
	rTable.getName = function()
		return self.firstname .. " " .. self.lastname
	end
	
	
	rTable.getFirstname = function()
		return self.firstname
	end
	
	rTable.getLastname = function()
		return self.lastname
	end

	rTable.getJob = function()
		return self.job
	end

	rTable.getJobgrade = function()
		return self.jobgrade
	end


	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end


	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	-- Returns a users permission level
	rTable.getPermissions = function()
		return self.permission_level
	end


	rTable.getIdentifier = function(i)
		return self.identifier
	end

	rTable.getGroup = function()
		return self.group
	end

	-- Global set
	rTable.set = function(k, v)
		self[k] = v
	end

	-- Global get
	rTable.get = function(k)
		return self[k]
	end


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