local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local Shared = Modules.Shared

local GoodSignal = require(Shared.Signal)

local CheckpointSignal = GoodSignal.new()

return CheckpointSignal