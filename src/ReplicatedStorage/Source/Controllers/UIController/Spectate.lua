local UI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Source = ReplicatedStorage.Source

local Modules = Source.Modules
local Utils = Modules.ClientUtils

local PromptSevice = require(Utils.PromptService)
local UIState = require(Modules.UIState)

local RootGui = shared.Loader.RootGui
local Menus = RootGui.Menus
local Frames = RootGui.Frames

local LeftButtons = Frames.Left

local SpectateButton = LeftButtons.Spectate
local SpectateFrame = Menus.Spectate

local Next = SpectateFrame.Next
local Previous = SpectateFrame.Previous

local Title = SpectateFrame.Title

local States = Modules.UIState

function UI._start()
	SpectateButton.MouseButton1Click:Connect(function()
		SpectateFrame.Visible = not SpectateFrame.Visible
	end)
end

return UI
