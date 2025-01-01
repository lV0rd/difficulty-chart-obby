-- tin
-- client
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

shared.Loader = require(ReplicatedStorage.Loader)
local Component = shared.Loader.Component

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local RootGui

repeat
	task.wait()
until PlayerGui:FindFirstChild("RootGui")
RootGui = PlayerGui:FindFirstChild("RootGui")

local Source = ReplicatedStorage.Source

local Start = os.time()

---Modules/Gui---
shared.Loader.RootGui = RootGui
shared.Loader.Modules = Source.Modules

---Controllers---
shared.Loader.InitModules(Source.Controllers)
shared.Loader.Start()

---Components---
local ComponentStart = os.time()
Component.Load(Source.Component)
shared.Loader.log.Print(script, "Components Loader Completed in : "..(os.time() - ComponentStart).."s")

local End = os.time() - Start

shared.Loader.log.Print(script, "Loader Completed in : "..(End).."s")
