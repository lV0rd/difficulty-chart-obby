local GUIObject = script.Parent
local RunService = game:GetService("RunService")

while RunService.Heartbeat:Wait() do
	GUIObject.Rotation += 1
end