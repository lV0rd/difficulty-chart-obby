local module = {}

--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--> Variables
local Source = ServerStorage.Source

local Signals = ReplicatedStorage.Signals
local Red = require(ReplicatedStorage.Red)
local Events = Signals.Server

local SharedModules = ReplicatedStorage.Modules
local ServerModules = Source.Modules

local Checkpoints = workspace.Checkpoint

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
	Char = require(SharedModules.Shared.Character)
}

local playerClass = require(ServerModules.Class.Player)

module.LoadedPlayers = {}

--> Private Functions

function onAdd(player)
	local Class = playerClass.new(player)
	
	Class:assignSpawnCallback(function(character)
		print("Spawned!")
		local rootPart : BasePart? = character:WaitForChild("HumanoidRootPart")
		if not rootPart then
			return
		end
		
		rootPart.CFrame = Checkpoints:FindFirstChild(tostring(Class.Data.currentSelectedCheckpoint)).CFrame * CFrame.new(0,3,0)
	end)
	
	Class:assignDeathCallback(function(character, humanoid)
		print("Died")
	end)
	
	Class:initCharacter()
	
	module.LoadedPlayers[player] = Class
end

function onRemove(player)
	if module.LoadedPlayers[player] then
		module.LoadedPlayers[player]:Destroy()
		module.LoadedPlayers[player] = nil
	end
end

--> Module Functions
function module.getPlayerClass(player) : any?
	return module.LoadedPlayers[player] or nil
end

--> Loader Methods
function module.Init()
	for _, player in Players:GetPlayers() do
		onAdd(player)
	end
	Players.PlayerAdded:Connect(onAdd)
	Players.PlayerRemoving:Connect(onAdd)
end

function module.Start()
	
end

return module