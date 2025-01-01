local module = {}

--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--> Variables
local LocalPlayer = Players.LocalPlayer
local Source = ReplicatedStorage.Source

local RootGui = shared.Loader.RootGui

local Signals = ReplicatedStorage.Signals
local Red = require(ReplicatedStorage.Red)
local Events = Signals.Client

local SharedModules  = ReplicatedStorage.Modules
local ClientModules = Source.Modules

local Checkpoints = workspace.Checkpoint

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
	Spr = require(SharedModules.Shared.spr)
}

local CheckpointEvent = Red.Client("Checkpoint")
local CheckpointSignal = require(Events.Checkpoint)

--> Private Functions
function example()
	print("Done!")
end

--> Module Functions
function module.DoSomething()
	print("Done!")
end

--> Loader Methods
function module.Init()
	
end

function module.Start()
		
	local Leaderstats = LocalPlayer:WaitForChild("leaderstats") :: Folder
	local CheckpointValue = Leaderstats:WaitForChild("Checkpoint") :: IntValue
	
	for i, v : BasePart? in Checkpoints:GetChildren() do
		if tonumber(v.Name) > CheckpointValue.Value then
			continue
		end
		v.Color = Color3.new(0.333333, 1, 0)
	end
	
	Checkpoints.ChildAdded:Connect(function(child)
		if not child:IsA("BasePart") then
			return
		end
		
		if tonumber(child.Name) > CheckpointValue.Value then
			return
		end
		
		child.Color = Color3.new(0.333333, 1, 0)
	end)
	
	CheckpointSignal:Fire(CheckpointValue.Value)
	
	CheckpointEvent:On("Claim", function(Stage, Data)
		print(Data)
		Utils.Spr.target(Checkpoints:FindFirstChild(tostring(Stage)), 1, 4, {Color = Color3.new(0.333333, 1, 0)})
		if Data[1] == Data[2] then
			print("happened")
			CheckpointSignal:Fire(Stage)
		end
	end)
	
	CheckpointEvent:On("SetStage", function(stage)
		CheckpointSignal:Fire(stage)
	end)
end

return module