function CreatePlayer(source, permission_level, money, bank, identifier, license, group, roles)
	local self = {}

	-- Initialize all initial variables for a user
	self.source = source
	self.permission_level = permission_level
	self.money = money
	self.bank = bank
	self.identifier = identifier
	self.license = license
	self.group = group
	self.session = {}
	self.roles = stringsplit(roles, "|")


	--ExecuteCommand('add_principal identifier.' .. self.identifier .. " group." .. self.group)
	local rTable = {}


	 
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