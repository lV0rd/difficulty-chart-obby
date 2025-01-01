local SETTINGS = {
	DebugMessages = true
}

local ComponentManager = {

}

----- Loaded Services -----
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

----- Private variables -----
local Children = {}

----- Private function -----
local function load(source)
	for _, component in source do
		local module_name = component.Name
		component = require(component)
		local tag = component.Tag

		assert(tag ~= nil, 
			("[ComponentManager] Module '%s' does not have a tag."):format(module_name))
		assert(Children[tag] == nil, 
			("[ComponentManager] Overlapping tag: '%s'"):format(tag))

		local babies = {}
		Children[tag] = babies

		local function component_added(item)
			local c = component.new(item)
			babies[item] = c
		end

		local function component_removed(item)
			local component = babies[item]

			if component ~= nil then
				if component.Destroy ~= nil then
					component:_cleanup()
					component:Destroy()
				end
				babies[item] = nil
			end
		end

		CollectionService:GetInstanceAddedSignal(tag):Connect(component_added)
		for _, item in ipairs(CollectionService:GetTagged(tag)) do
			component_added(item)
		end
		CollectionService:GetInstanceRemovedSignal(tag):Connect(component_removed)
	end
end

----- Global methods -----
function ComponentManager.GetComponent(model, tag)
	assert(model ~= nil and tag ~= nil, 
		"[ComponentManager] Invalid tag or model.")
	assert(Children[tag] ~= nil, 
		("[ComponentManager] '%s' is not a registed component."):format(tag))
	assert(ComponentManager.HasTag(model, tag) == true,
		("[ComponentManager] '%s' does not have the tag '%s'"):format(model.Name, tag))

	return Children[tag][model]
end


function ComponentManager.GetComponents(model)
	assert(model ~= nil, 
		"[ComponentManager] Invalid model.")

	local Tags = CollectionService:GetTags(model)
	local Components = {}

	for _, tag in ipairs(Tags) do
		Components[tag] = ComponentManager.GetComponent(model, tag)
	end

	return Components
end


function ComponentManager.HasTag(item, tag)
	return CollectionService:HasTag(item, tag) == true
end


function ComponentManager.IsDescendantOfComponent(child, tag)
	while child ~= nil and ComponentManager.HasTag(child, tag) == false do
		child = child.Parent
	end

	return child ~= nil, child
end


function ComponentManager.Load(components)
	if type(components) ~= "table" then
		components = components:GetChildren()
	end

	load(components)
end


return ComponentManager
