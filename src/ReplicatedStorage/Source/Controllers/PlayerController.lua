local module = {}
local player

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

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
}

local PlayerClass = require(Source.Modules.Class.Player)
local InputSignal = require(Events.Input)

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
	
	
	player = PlayerClass.new(LocalPlayer, function(Character)
		print("Spawned")
	end, function(Character, Humanoid)
		print("Died")
	end)
	
	InputSignal:Connect(function(input)
		if input == "R" then
			print("Input")
		end
	end)
end

function module.Start()
	
end

return module