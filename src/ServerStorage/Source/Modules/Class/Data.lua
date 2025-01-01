--!nocheck
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--modules
local Source = ServerStorage.Source
local Modules = Source.Modules
local Info = Modules.Info
local ProfileService = require(Modules.ProfileService)
local Promise = require(ReplicatedStorage.Modules.Shared.promise)

local ProfileTemplate = require(Info.ProfileTemplate)
local ProfileKey = require(Info.ProfileKey)

local ProfileStore = ProfileService.GetProfileStore(
    ProfileKey,
    ProfileTemplate
)

local Profiles = {}
local DataHandler = {}
DataHandler.__index = DataHandler

function DataHandler.new(player: Player)
	local self = setmetatable(
		
		{	player = player,
			profile = nil,
			checkpointStat = 0,
			currentSelectedCheckpoint = 0
		}
		
	, DataHandler)
	
    self.dataLoadPromise = Promise.new(function(resolve, reject)
        local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
        if profile ~= nil then
            profile:AddUserId(player.UserId) -- GDPR compliance
            profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
            profile:ListenToRelease(function()
                Profiles[player] = nil
                -- The profile could've been loaded on another Roblox server:
                player:Kick()
                reject()
            end)
            if player:IsDescendantOf(Players) == true then
                Profiles[player] = profile
                -- A profile has been successfully loaded:
                self.profile = profile
				self.currentSelectedCheckpoint = profile.Data.Checkpoint
				
                --leaderboard setup
                local leaderstats = Instance.new("Folder")
                leaderstats.Name = "leaderstats"
                leaderstats.Parent = player

                local checkpointStat = Instance.new("IntValue")
				checkpointStat.Name = "Checkpoint"
				checkpointStat.Value = profile.Data.Checkpoint
				checkpointStat.Parent = leaderstats
				self.checkpointStat = checkpointStat
				self.currentSelectedCheckpoint = profile.Data.Checkpoint

                resolve(profile)
            else
                -- Player left before the profile loaded:
                profile:Release()
                reject()
            end
        else
            player:Kick("Data unsuccessfully loaded, rejoin and try again. If issue persists pleasse contact developers.")
            reject()
        end
    end)

    return self
end

function DataHandler:unload()
    if self.dataLoadPromise then
        self.dataLoadPromise:cancel()
    end
    local profile = Profiles[self.player]
    if profile ~= nil then
        profile:Release()
    end
end

function DataHandler:Destroy()
    self:unload()
    table.clear(self)
    setmetatable(self, nil)
end

function DataHandler:getProfileAsync()
    if self.profile then
        return self.profile
    else
        local _, profile = self.dataLoadPromise:await()
        return profile
    end
end

function DataHandler:getData()
    local profile = self:getProfileAsync()

    return profile.Data
end

function DataHandler:setCoinAmount(v: number): nil
    self:getData().Coins = v
end

function DataHandler:setCheckpoint(v: number): boolean
	if self:getData().Checkpoint >= v then
		return false
	end
	if self:getData().Checkpoint + 1 ~= v then
		return false
	end
	
	if self:getData().Checkpoint == self.currentSelectedCheckpoint then
		print(self.currentSelectedCheckpoint)
		self.currentSelectedCheckpoint = v
	end
	
	self:getData().Checkpoint = v
	self.checkpointStat.Value = v
	return true
end

function DataHandler:setStage(v: number, Type)
	if Type == "Back" then
		v = -v
	end
	local stageToSet
	if self.currentSelectedCheckpoint > 0 then
		stageToSet = math.clamp(self.currentSelectedCheckpoint + v, 0, self:getData().Checkpoint)
		self.currentSelectedCheckpoint = stageToSet
	else
		stageToSet = self.profile.Data.Checkpoint
		self.currentSelectedCheckpoint = stageToSet
	end
	print("Stage result:", stageToSet)
	
	return true, stageToSet
end

function DataHandler:incrementCoinAmount(v: number): nil
    self:setCoinAmount(self:getData().Coins + v)
end

return DataHandler