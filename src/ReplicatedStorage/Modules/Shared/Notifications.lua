local RunService = game:GetService("RunService")
local Client = {}
local Server = {}

local RootGui : ScreenGui?

if RunService:IsServer() then
	return Server
elseif RunService:IsClient() then
	RootGui = shared.Loader.RootGui
	return Client
end

--CLIENT
function Client.Notify(Message : string, Color : Color3, Animation : string):nil
	print("Notified")
end

--SERVER
function Server.NotifyClient(Player : Player, Message : string, Color : Color3, Animation : string):nil
	print("Notified", Player)
end

function Server.NotifyList(Players : {Player}, Message : string, Color : Color3, Animation : string):nil
	print("Notified", Players)
end

function Server.NotifyAll(Message : string, Color : Color3, Animation : string):nil
	print("Notified everyone")
end