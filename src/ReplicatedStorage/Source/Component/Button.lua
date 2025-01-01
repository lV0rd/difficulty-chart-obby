--> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--> Settings
local SETTINGS = {
	Tag = script.Name;	
}

--> Define Component
local Component = {Tag = SETTINGS.Tag}
Component.__index = Component

--> Variables
local LocalPlayer = Players.LocalPlayer
local Source = ReplicatedStorage.Source

local RootGui = shared.Loader.RootGui :: ScreenGui?

local Signals = ReplicatedStorage.Signals
local Red = require(ReplicatedStorage.Red)
local Events = Signals.Client

local SharedModules  = ReplicatedStorage.Modules
local ClientModules = Source.Modules

--> References
local Utils = {
	Maid = require(SharedModules.Shared.Maid);
	Spr = require(SharedModules.Shared.spr)
}

--> Constructor
function Component.new(instance : TextButton | ImageButton)
	local self = setmetatable({
		["_initialized"] 	= false;
		["Instance"] 		= instance;
		["debounce"]        = false;
		["debounce_time"]   = .5;
		["connections"] = Utils.Maid.new()

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
	
	local UIScale = self.Instance:FindFirstChildOfClass("UIScale")
	if not UIScale then
		warn("Add a UIScale to: ", self.Instance.Name)
		return
	end
	
	local OriginalSize = 1
	local HoverSize = 1.1
	local ClickSize = .9

	self.connections:GiveTask(self.Instance.MouseButton1Down:Connect(function()
		Utils.Spr.target(UIScale, 1, 7, {Scale = ClickSize})
	end))
	
	self.connections:GiveTask(self.Instance.MouseButton1Up:Connect(function()
		Utils.Spr.target(UIScale, 1, 7, {Scale = OriginalSize})
	end))
	
	self.connections:GiveTask(self.Instance.MouseEnter:Connect(function()
		Utils.Spr.target(UIScale, 1, 7, {Scale = HoverSize})
	end))
	
	self.connections:GiveTask(self.Instance.MouseLeave:Connect(function()
		Utils.Spr.target(UIScale, 1, 7, {Scale = OriginalSize})
	end))
end

function Component:_cleanup()
	if self._initialized == false then return end
	self.connections:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return Component