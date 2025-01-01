local player = {}
player.__index = player

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Modules = ReplicatedStorage.Modules
local Utils = Modules.Shared
local Classes = ServerStorage.Source.Modules.Class
local Data = require(Classes.Data)

local Maid = require(Utils.Maid)

function player.new(Player: Player, characterAddedCallback : ((Character : Model) -> ())?, characterDiedCallback : ((Character : Model, Humanoid : Humanoid) -> ())?)
	local self = setmetatable({}, player)

	self.Player = Player
	self.Character = nil
	self.Humanoid = nil
	self.Connections = Maid.new()
	self.Callback = characterAddedCallback
	self.DiedCallback = characterDiedCallback
	self.Data = Data.new(Player)
	
	self.Connections:GiveTask(function()
		print(`{Player.Name} left the game.`)
	end)

	return self
end

function player:assignSpawnCallback(characterAddedCallback : ((Character : Model) -> ())?)
	self.Callback = characterAddedCallback
end

function player:assignDeathCallback(characterDiedCallback : ((Character : Model, Humanoid : Humanoid) -> ())?)
	self.DiedCallback = characterDiedCallback
end

function player:initCharacter()
	if self.Player.Character then
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

function player:setStage(Amount : number, Type : string)
	local data = self.Data
	local success, stage = data:setStage(Amount, Type)
	return success, stage
end

function player:setCheckpoint(checkpoint: number)
	local data = self.Data
	local success = data:setCheckpoint(checkpoint)
	return success
end

function player:destroy()
	self.Connections:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return player