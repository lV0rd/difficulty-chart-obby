repeat task.wait() until shared.Loader

--> Variables
local Loader = shared.Loader
Loader.YieldUntilInitialized()

local UI = Loader.Get("UIController")

--> Constants
local STUDIO_RESOLUTION = Vector2.new(1920, 1080)

---------->
UI.YieldUntilLoaded()

local objects = {}

local function getDescendant(descendant)
	local object = objects[descendant]

	if not object then
		objects[descendant] = {}
		object = objects[descendant]
	end

	return object
end

local function scaleDescendant(descendant)
	if descendant:IsA("UIStroke") then
		local object = getDescendant(descendant)

		if not object.UIStroke then
			object.UIStroke = {}
		end

		if not object.UIStroke.Thickness then
			object.UIStroke.Thickness = descendant.Thickness
		end

		descendant.Thickness = object.UIStroke.Thickness / ((STUDIO_RESOLUTION.X + STUDIO_RESOLUTION.Y) / 2) * ((workspace.CurrentCamera.ViewportSize.X + workspace.CurrentCamera.ViewportSize.Y) / 2)
	elseif (descendant:IsA("ImageLabel") or descendant:IsA("ImageButton")) and descendant["ScaleType"] == Enum.ScaleType.Slice then
		local object = getDescendant(descendant)

		if not object.Slice then
			object.Slice = {}
		end

		if not object.Slice.Scale then
			object.Slice.Scale = descendant.SliceScale
		end

		descendant.SliceScale = (workspace.CurrentCamera.ViewportSize.X / STUDIO_RESOLUTION.X) * object.Slice.Scale
	end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	for _, descendant in pairs(Loader.Player.PlayerGui:GetDescendants()) do
		scaleDescendant(descendant)
	end
end)

for _, descendant in pairs(Loader.Player.PlayerGui:GetDescendants()) do
	scaleDescendant(descendant)
end

Loader.Player.PlayerGui.DescendantAdded:Connect(function(descendant)
	scaleDescendant(descendant)
end)