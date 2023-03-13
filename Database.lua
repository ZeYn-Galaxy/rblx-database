local Database = {}
Database.__index = Database

local GlobalData = {}

--// Module
local GoodSignal = require(script.Parent._GoodSignal)

--// Services
local DB = game:GetService("DataStoreService")
local Data = DB:GetDataStore("WormDataNew")

local Method = script.Parent.Method
local Single = require(Method.SingleMethod)

function getData(userId)
	for i,v in pairs(GlobalData) do
		if v.UserId == userId then
			return i
		end
	end
	
	return false
end

function Database:Load(plr)
	local data = nil
	
	local success, err = pcall(function()
		data = Data:GetAsync(plr.UserId.."_Data")
	end)
	
	if success then
		
		if data ~= nil then
			
			table.insert(GlobalData, 
				{
					UserId = plr.UserId,
					Data = data,
					Version = 0
				})
			
			Database.Changed(plr)
			
			local plrData = Database:GetDataPlayer(plr)
			
			if plrData then
				for name, obj in pairs(plrData["Data"]) do
					if obj.Method == "Single" then
						Database.Single(name, obj.Value, plr)
					end
				end
			end
			
			print("Data Loaded!")
			return
		end
		
		print("Creating new data!")
		
		table.insert(GlobalData, 
			{
				UserId = plr.UserId,
				Data = {},
				Version = 0
			})
		
		Database.Changed(plr)
		local s,r = pcall(function()
			Data:SetAsync(plr.UserId.."_Data", {})
		end)
		
		if s then
			print("Data Berhasil Dibuat")
		end
		
		
	else
		error(err)
	end
end


function Database:Save(plr)
	
	local index = getData(plr.UserId)
	if not index then return end
	
	local playerData = GlobalData[index]
	print(playerData)
	local success, err = pcall(function()
		Data:UpdateAsync(plr.UserId.."_Data", function(oldData)
			if playerData.Version > 0 then
				print("Data Saved!")
				return playerData.Data
			else
				print("Data tidak berubah")
			end
		end)
	end)
end
--// Create a new meta
function Database.Single(name, default, player)
	return Single.new(name, default, Database:GetDataPlayer(player))
end


function Database:GetDataPlayer(plr)
	local index = getData(plr.UserId)
	if index then
		return GlobalData[index]
	end
	return false
end


function Database.Changed(plr)
	local plrData = Database:GetDataPlayer(plr)
	if plrData then
		
		plrData["OnChanged"] = GoodSignal.new()
		
		return plrData["OnChanged"]
	end
end

function Database:Get(name, plr)
	local plrData = Database:GetDataPlayer(plr)
	
	if plrData then
		if not plrData["Data"][name] then return end
		return plrData["Data"][name]
	end
end

return Database