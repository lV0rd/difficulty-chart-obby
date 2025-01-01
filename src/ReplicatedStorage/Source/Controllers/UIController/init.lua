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

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
	Signal = require(SharedModules.Shared.Signal);
}

local UI = {}
local Signal = Utils.Signal.new()
local Initialized = false

--> Private Functions
function example()
	print("Done!")
end

--> Module Functions
function module.YieldUntilLoaded()
	if not Initialized then
		Signal:Wait()
	end
end

--> Loader Methods
function module.Init()
	for i, v in script:GetChildren() do
		if v:IsA("ModuleScript") then
			local module = require(v)
			UI[v.Name] = module
		end
	end
	Initialized = true
	Signal:Fire()
end

function module.Start()
	for i, k in UI do
		if typeof(k) == "table" and typeof(rawget(k, "_start")) == "function" then
			task.spawn(k._start)
			print(`[{script.Name}]: {i} started.`)
		end
	end
end

return module