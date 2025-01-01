local UI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local Source = ReplicatedStorage.Source

local Modules = Source.Modules
local Utils = Modules.ClientUtils

local PromptSevice = require(Utils.PromptService)
local UIState = require(Modules.UIState)

local RootGui = shared.Loader.RootGui :: ScreenGui
local Frames = RootGui.Frames
local LeftSide = Frames.Left

local InviteButton : TextButton = LeftSide.Invite

local LocalPlayer = Players.LocalPlayer

function UI._start()
	InviteButton.MouseButton1Click:Connect(function()
		SocialService:PromptGameInvite(LocalPlayer)
	end)
end

return UI
