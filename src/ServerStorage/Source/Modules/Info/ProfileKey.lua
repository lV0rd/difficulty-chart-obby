local RunService = game:GetService("RunService")
if RunService:IsStudio() then
	return "Test"..tostring(tick())
end

return "Key"