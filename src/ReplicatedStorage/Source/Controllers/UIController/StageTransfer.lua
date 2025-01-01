local UI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local Source = ReplicatedStorage.Source
local Events = ReplicatedStorage.Signals.Client

local Modules = Source.Modules
local Utils = Modules.ClientUtils

local PromptSevice = require(Utils.PromptService)
local UIState = require(Modules.UIState)
local Red = require(ReplicatedStorage.Red)

local StageTransferEvent = Red.Client("StageTransfer")

local RootGui = shared.Loader.RootGui :: ScreenGui?
local Frames = RootGui.Frames

local Top = Frames.Top
local CheckpointFrame = Top.Checkpoint

local CheckpointFrameObjects = {
	AdvancedOne = CheckpointFrame.AdvanceOne :: TextButton;
	AdvancedTen = CheckpointFrame.AdvanceTen :: TextButton;
	BackOne = CheckpointFrame.BackOne :: TextButton;
	BackTen = CheckpointFrame.BackTen :: TextButton;
	CurrentStage = CheckpointFrame.CurrentStage :: TextBox;
}

local LocalPlayer = Players.LocalPlayer
local CheckpointSignal = require(Events.Checkpoint)

function onCheckpointSignal(stage: number)
	CheckpointFrameObjects.CurrentStage.Text = stage
end

function onBackOne()
	StageTransferEvent:Fire("Transfer", "Back", 1)
end


function onBackTen()
	StageTransferEvent:Fire("Transfer", "Back", 10)	
end

function onAdvancedOne()
	StageTransferEvent:Fire("Transfer", "Advanced", 1)
end


function onAdvancedTen()
	StageTransferEvent:Fire("Transfer", "Advanced", 10)
end

function UI._start()
	CheckpointSignal:Connect(onCheckpointSignal)
	
	CheckpointFrameObjects.BackOne.MouseButton1Click:Connect(onBackOne)
	CheckpointFrameObjects.BackTen.MouseButton1Click:Connect(onBackTen)
	
	CheckpointFrameObjects.AdvancedOne.MouseButton1Click:Connect(onAdvancedOne)
	CheckpointFrameObjects.AdvancedTen.MouseButton1Click:Connect(onAdvancedTen)
end

return UI
