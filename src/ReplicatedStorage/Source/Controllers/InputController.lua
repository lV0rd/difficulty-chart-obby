local module = {}

--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		
		if input.KeyCode == Enum.KeyCode.R then
			InputSignal:Fire("R")
		end
		
	end)
end

function module.Start()

end

return module