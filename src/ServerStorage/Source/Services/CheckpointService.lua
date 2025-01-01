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

local CheckpointEvent = Red.Server("Checkpoint")
local StageTransferEvent = Red.Server("StageTransfer")

local Debounce = {}

--> Private Functions
function exmp()
	
end

--> Module Functions
function module.exmp()
	
end

--> Loader Methods
function module.Init()
	
end

function module.Start()
	local PlayerService = require(Source.Services.PlayerService)
	local PlayerClasses = PlayerService.LoadedPlayers
	
	for _, checkpoint: BasePart in Checkpoints:GetChildren() do
			checkpoint.Touched:Connect(function(hit: BasePart)	
			local Character, Humanoid = Utils.Char.getCharacterFromInstance(hit)
			if (not Character) or (not Humanoid) then
				return
			end

			local Player = Utils.Char.getPlayerFromCharacter(Character)
			if not Player then
				return
			end
			
			local PlayerObject = PlayerService.getPlayerClass(Player)
			if not PlayerObject then
				warn("No player object found for", Player.Name)
			end
			
			local success = PlayerObject:setCheckpoint(tonumber(checkpoint.Name))
			if success then
				local CurrentStage = PlayerObject.Data.profile.Data.Checkpoint
				local SelectedStage = PlayerObject.Data.currentSelectedCheckpoint
				CheckpointEvent:Fire(Player, "Claim", tonumber(checkpoint.Name), {CurrentStage, SelectedStage})
			end
		end)
	end
	
	StageTransferEvent:On("Transfer", function(Player : Player, Type : string, Amount : number)
		local PlayerObject = PlayerService.getPlayerClass(Player)
		if not PlayerObject then
			warn("No player object found for", Player.Name)
		end
		
		local success, stage = PlayerObject:setStage(Amount, Type)
		if success then
			local Root = Utils.Char.getAlivePlayerRootPart(Player)
			if Root then Root.CFrame = Checkpoints:FindFirstChild(tostring(stage)).CFrame * CFrame.new(0,3,0) end
			CheckpointEvent:Fire(Player, "SetStage", stage)
		end
	end)
	
end

return module