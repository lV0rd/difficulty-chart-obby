local player = {}
player.__index = player

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Modules = ReplicatedStorage.Modules
local Utils = Modules.Shared

local Maid = require(Utils.Maid)

function player.new(Player: Player, characterAddedCallback : ((Character : Model) -> ())?, characterDiedCallback : ((Character : Model, Humanoid : Humanoid) -> ())?)
	local self = setmetatable({}, player)

	self.Player = Player
	self.Character = nil
	self.Humanoid = nil
	self.Connections = Maid.new()
	self.Callback = characterAddedCallback
	self.DiedCallback = characterDiedCallback

	self:initCharacter()

	return self
end

function player:initCharacter()
	if self.Player.Character  then
		self:loadCharacter()
	end

	self.Connections:GiveTask(self.Player.CharacterAdded:Connect(function()
		self:loadCharacter()
	end))
end

function player:loadCharacter()
	self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
	self.Humanoid = self.Character.Humanoid
	self.Humanoid.Died:Once(function()
		if self.DiedCallback then
			self.DiedCallback(self.Character, self.Humanoid)
		end
	end)
	if self.Callback then
		self.Callback(self.Character)
	end
end

function player:destroy()
	self.Connections:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return player