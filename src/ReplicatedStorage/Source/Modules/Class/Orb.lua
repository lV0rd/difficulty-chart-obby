local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules

local Utils = {
	Maid = require(Modules.Shared.Maid)
}

local Orbs = {}
Orbs.__index = Orbs

function Orbs.new(Orb : BasePart)
	local self = setmetatable({}, Orbs)
	
	self.Connections = Utils.Maid.new()
	self.Orb = Orb
	
	self:Launch()
	
	return self
end

function Orbs:Launch()
	self.Orb:ApplyImpulse(Vector3.new(math.random() * 10, 10, math.random() * 10))
end

function Orbs:Collect()
	--Collect
	Orbs:Destroy()
end

function Orbs:Destroy()
	self.Connections:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return Orbs
