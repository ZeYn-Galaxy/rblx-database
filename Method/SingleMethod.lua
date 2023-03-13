local Single = {}
Single.__index = Single

local goodSignal = require(script.Parent.Parent._GoodSignal)

function Single.new(currency: string, default: any, playerData)
	
	if not playerData["Single"] then
		playerData["Single"] = {}
	end
	
	
	if playerData["Single"][currency] then
		return playerData["Single"][currency]
	end
	
	if not playerData["Data"][currency] then
		playerData["Data"][currency] = { Value = default, Method = "Single" }
	end
	
	local Meta =  setmetatable({
		name = currency,
		value = playerData["Data"][currency].Value,
		plrData = playerData
	}, Single)
	
	playerData["Single"][currency] = Meta
	
	return playerData["Single"][currency]
end


function Single:Increment(value)
	self.plrData["Data"][self.name].Value += value
	self.plrData.Version += 1
	self.plrData["OnChanged"]:Fire(self.name, self.plrData["Data"][self.name].Value)
end

function Single:Set(value)
	self.plrData["Data"][self.name].Value = value
	self.plrData.Version += 1
	self.plrData["OnChanged"]:Fire(self.name, self.plrData["Data"][self.name].Value)
end

return Single