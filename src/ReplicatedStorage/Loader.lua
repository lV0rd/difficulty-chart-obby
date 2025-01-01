local loader = {
	log = {};
	test = {};
}

loader.__index = loader

loader.RootGui = nil
loader.Modules = nil

loader.Player = nil

local backend = {
	modules = {};
	tests = {};
	utils = {};
	initBool = false;
}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

if RunService:IsClient() then
	loader.Player = Players.LocalPlayer
end

---- Utils ----
local Utils = ReplicatedStorage.Modules.Shared
local Maid = require(Utils.Maid)
local Signal = require(Utils.GoodSignal)

loader.Component = require(Utils.Component)

---- EVENTS ----
loader.OnComplete = Signal.new()

---- Backend Methods ----
function backend.init(m)
	if m:GetAttribute("_loaderIgnore") then return end
	local existingModule = backend.modules[m.Name]

	if existingModule then
		loader.log.Warn(script, "Duplicate Module Name! : " .. m.Name)
		return
	end

	backend.modules[m.Name] = require(m)
	backend.modules[m.Name].Init()
	loader.log.Print(script, "Initialized "..m.Name)
end


---- Loader Methods ----
function loader.YieldUntilInitialized()
	if not backend.initBool then
		loader.OnComplete:Wait()
	end
end

function loader.Get(name)
	local module = backend.modules[name]
	if module == nil then
		loader.log.Warn(script, string.format("Failed to get module: %s", name))
		return nil
	else
		return module
	end
end

function loader.GetAllModules()
	return backend.modules
end

function loader.WaitFor(name : string, timeout : number) -- YIELDS!
	timeout = timeout or 5
	local module = backend.modules[name]
	local start = os.time()

	while module == nil do
		if os.time() - start >= timeout then
			module = "non"
			warn(string.format("Infinite yield on module: %s", name))
			return nil
		end
		module = backend.modules[name]
		wait(.01)
	end

	return module
end

function loader.InitModulesDeep(root : {any}?)
	local start = os.time()
	if (type(root) ~= "table") then
		root = root:GetDescendants()
	end

	for _, i in pairs(root) do
		if i:IsA("ModuleScript") == false then continue end
		if i:GetAttribute("LoaderIgnored") then continue end

		backend.init(i)
	end
	backend.initBool = true
	loader.OnComplete:Fire()
	loader.log.Print(script, "Loader initialized modules in : ".. os.time() - start)
end

function loader.InitModules(root : {any}?)
	local start = os.time()
	if (type(root) ~= "table") then
		root = root:GetChildren()
	end

	for _, i in pairs(root) do
		if i:IsA("ModuleScript") == false then continue end
		if i:GetAttribute("LoaderIgnored") then continue end

		backend.init(i)
	end
	backend.initBool = true
	loader.OnComplete:Fire()
	loader.log.Print(script, "Loader initialized modules in : ".. os.time() - start)
end

function loader.InitModulesInOrder(root : {ModuleScript}?)
	local start = os.time()
	if (type(root) ~= "table") then
		error("Root must be a table of modulescripts! {ModuleScript}")
	end

	for _, i in pairs(root) do
		if i:IsA("ModuleScript") == false then continue end
		if i:GetAttribute("_loaderIgnore") then continue end

		backend.init(i)
	end
	backend.initBool = true
	loader.OnComplete:Signal()
	loader.log.Print(script, "Loader initialized modules in : ".. os.time() - start)
end

function loader.Start()
	local start = os.time()
	for name, module in pairs(backend.modules) do
		if module.Start and type(module.Start) == "function" then
			task.spawn(module.Start)
			loader.log.Print(script, "Started "..name)
		end
	end
	loader.log.Print(script, "Loader started modules in : ".. os.time() - start)
end

function loader.GetUtil(name : string)
	if backend.utils[name] then
		return backend.utils[name]
	else
		local util = Utils:FindFirstChild(name)
		assert(util ~= nil, string.format("[loader] Util '%s' does not exist.", name))
		backend.utils[name] = require(util)
		return backend.utils[name]
	end
end

function loader.ClearAllWhichIsA(instance : Instance, className : string)
	for _, c in instance:GetChildren() do
		if c:IsA(className) then
			c:Destroy()
		end
	end
end

function loader.LoadChildren(folder : Folder) : {string : {any}}
	local t = {}
	for _, inst in folder:GetChildren() do
		if inst:IsA("ModuleScript") then
			t[inst.Name] = require(inst)
		end
	end
	return t
end

-- Credit: @Quenty
function loader.Maid()
	return Maid.new()
end

-- Credit: @Quenty
function loader.Signal()
	return Signal.new()
end


function loader.Spring(...)
	return Spring.new(...)
end

-- Credit: @loleris
function loader.NewInstance(class : string, properties : {string : any})
	local instance = Instance.new(class)
	for k, v in pairs(properties) do
		if k ~= "Parent" then
			instance[k] = v
		end
	end
	instance.Parent = properties.Parent or workspace
	return instance
end

function loader.SafeTableRemove(tbl : {any}, element : any)
	local index = table.find(tbl, element)
	if index ~= nil then
		table.remove(tbl, index)
		return true
	end
	return false
end

function loader.DeepCopy(original : {any})
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = loader.DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

---- LOGGING ----
function loader.log.Warn(source : Instance, ...)
	warn("["..source.Name.."]: ",...)
end

function loader.log.Print(source : Instance, ...)
	print("["..source.Name.."]: ",...)
end

function loader.log.fPrint(source : Instance, fstring : string, ...)
	print("["..source.Name.."]: ",string.format(fstring, ...))
end

function loader.log.Error(source : Instance, ...)
	error("["..source.Name.."]: " .. tostring(...))
end

---- TESTS ----
function loader.test.AddTest(name : string, func : (any) -> (any))
	backend.tests[name] = func
end

function loader.test.RunTests()
	if not game.ReplicatedStorage:GetAttribute("Loader_RunTests") then
		loader.log.Warn(script, "Tests not enabled!")
		return
	end

	local pass = 0
	local fail = 0
	local invalid = 0
	local total = 0

	print("---- Test Begin ----")

	for name, test in pairs(backend.tests) do
		local test_result = test()
		if test_result == false then
			print("❌ Test Failed - " .. name)
			fail += 1
		elseif test_result == true then
			print("✔️ Test Passed - " .. name)
			pass += 1
		else
			print("⚠️ Non-Boolean Test Result - " .. name)
			invalid += 1
		end

		total += 1
	end

	print()
	print(total .. " total tests")
	print(pass .. " tests passed")
	print(fail .. " tests failed")
	print(invalid .. " invalid tests")

	print("--- Test End ----")
end

_G.Get = loader.Get

return loader