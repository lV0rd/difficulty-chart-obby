local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local Shared = Modules.Shared

local GoodSignal = require(Shared.Signal)

local InputSignal = GoodSignal.new()

return InputSignal