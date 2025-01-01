--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

--> Settings
local SETTINGS = {
	Tag = script.Name;	
}

--> Define Component
local Component = {Tag = SETTINGS.Tag}
Component.__index = Component

--> Variables
local Source = ServerStorage.Source

local Signals = ReplicatedStorage.Signals
local Red = require(ReplicatedStorage.Red)
local Events = Signals.Server

local ServerModules = Source.Modules
local SharedModules = ReplicatedStorage.Modules

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
	Char = require(SharedModules.Shared.Character)
}

--> Constructor
function Component.new(instance : BasePart)
	local self = setmetatable({
		["_initialized"] 	= false;
		["Instance"] 		= instance;
		["debounce"]        = false;
		["debounce_time"]   = .5;
		["connections"] = Utils.Maid.new();
		["playerDebounce"] = {};
		["damage"] = 10
	}, Component)

	self:_init()
	return self
end

function Component:_init()
	if self._initialized == true then return end
	self._initialized = true

	self.connections:GiveTask(function()
		print("Cleaned!")
	end)

	--Events (use maid)
	self.connections:GiveTask(self.Instance.Touched:Connect(function(hit)
		local Character, Humanoid = Utils.Char.getCharacterFromInstance(hit)
		if not Character then
			return
		end

		local Player = Players:GetPlayerFromCharacter(Character)
		if not Player then
			return
		end
		
		if self.playerDebounce[Player] then
			return
		end
		
		self.playerDebounce[Player] = true
		
		Humanoid:TakeDamage(self.damage)
		task.wait(.2)
		
		self.playerDebounce[Player] = nil
	end))

end

function Component:_cleanup()
	if self._initialized == false then return end
	self.connections:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return Component