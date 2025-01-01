--[[
	@Tin PromptService
	
	Simple module for a clean way of prompting gamepass/dev product
	
	HOW TO USE:
		Put PurchaseFrame inside anything and use this code right here to prompt:
		
		[
		local Player = game.Players.LocalPlayer
		local Module = require(Path.To.Module)
		local RootGui = --Path to the screen gui that has the child/descendant "PurchaseFrame"
		--MAKE SURE ROOTGUI HAS THE DESCENDANT PURCHASEPROMPT--
		--MAKRE SURE THERES NOTHING ELSE CALLED PURCHASEPROMPT--
		
		local Id = --Id
		
		--Gamepass
		Module:Prompt("Gamepass", Id)
		--Dev Product
		Module:Prompt("Product", Id)
		]
	
]]

--> Services
local MarketPlaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--> Variables
local LocalPlayer = Players.LocalPlayer

local RootGui = shared.Loader.RootGui :: ScreenGui
local PurchaseFrame = script.PurchaseFrame
PurchaseFrame.Parent = RootGui

local module = {}
module.CurrentId = nil

--small maid class

--Start of maid
local class = {} 
class.__index = class

function class.new()
	return setmetatable({}, class)
end

function class:Destroy()
	for i, v in self do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
			v = nil
		end
	end
end

class.DoCleaning = class.Destroy
class.Clean = class.Destroy

function class:Clear()
	self:Destroy()
	setmetatable(self, nil)
end
--End of maid

local connections = class.new()


--> Private Functions 
function Assert(Condition : boolean, Message : string) --Custom assert, check for condition, if false then error.
	if not Condition then
		error(Message)
	end	
end

function CheckGamepassOwnership(Id : number) --Check if player already owns gamepass
	local success, result = pcall(function()
		return MarketPlaceService:UserOwnsGamePassAsync(LocalPlayer, Id)
	end)
	
	if not success then
		return false
	end
	
	if result then
		return true
	else
		return false
	end
end

--> Module Functions
function module:Prompt(Type : string, Id : number)
	Assert(type(Type) == "string", "Type must be a string that is either 'Gamepass' or 'Product'")
	Assert(type(Id) == "number", "Id must be a number that is an ID")
	--Check the types of each argument, if one is wrong, code stops.
	
	Assert(module.CurrentId == nil, "Module already running")
	--Check if prompt is already called, if yes, code stops.
	
	--Find the CanvasGroup of the prompt, if it doesnt exist, code stops.
	
	if Type == "Gamepass" then
		local Ownership = CheckGamepassOwnership(Id)
		if Ownership then
			warn("User already owns gamepass : ", Id)
			return
		end
	end
	
	module.CurrentId = Id
	
	local TweenIn = TweenService:Create(PurchaseFrame, TweenInfo.new(0.4), {
		GroupTransparency = 0
	})
	local TweenOut = TweenService:Create(PurchaseFrame, TweenInfo.new(0.4), {
		GroupTransparency = 1
	})
	
	TweenIn:Play()
	--Play a fade in animation of the CanvasGroup
	
	TweenIn.Completed:Wait() --Yield until tween is completed.
	
	if Type == "Gamepass" then
		MarketPlaceService:PromptGamePassPurchase(LocalPlayer, Id)
		
		connections.Hey = MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, was)
			if plr ~= LocalPlayer then
				return
			end
			
			if id ~= Id then
				return
			end

			if module.CurrentId == nil then
				return
			end

			if module.CurrentId ~= Id then
				return
			end
			
			TweenOut:Play()
			connections:Destroy()
			module.CurrentId = nil
		end)
	else
		MarketPlaceService:PromptProductPurchase(LocalPlayer, Id)
		
		connections.Hey = MarketPlaceService.PromptProductPurchaseFinished:Connect(function(plrId, id, was)
			if plrId ~= LocalPlayer.UserId then
				return
			end
			
			if id ~= Id then
				return
			end
			
			if module.CurrentId == nil then
				return
			end
			
			if module.CurrentId ~= Id then
				return
			end
			
			TweenOut:Play()
			connections:Destroy()
			module.CurrentId = nil	
		end)
	end
	
	task.delay(25, function()
		if module.CurrentId == nil then
			return
		end
		
		if module.CurrentId ~= Id then
			return
		end
		
		if not TweenOut then
			return
		end
		
		TweenOut:Play()
		connections:Destroy()
		module.CurrentId = nil		
	end)
	
end

return module