-- tin
-- client
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

shared.Loader = require(ReplicatedStorage.Loader)
local Component = shared.Loader.Component

local Source = ServerStorage.Source

local Start = os.time()

---Services---
shared.Loader.InitModules(Source.Services)
shared.Loader.Start()

---Components---
local ComponentStart = os.time()
Component.Load(Source.Component)
shared.Loader.log.Print(script, "Components Loader Completed in : "..(os.time() - ComponentStart).."s")

local End = os.time() - Start

shared.Loader.log.Print(script, "Loader Completed in : "..(End).."s")
