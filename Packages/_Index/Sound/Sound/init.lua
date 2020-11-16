--[[

// Sound.lua
// straightforward database-rounded library for playing sounds
// @Vexitory
// 11.12.2020

]]

--// SERVICES

local SoundService = game:GetService('SoundService')
local CollectionService = game:GetService('CollectionService')
local ContentProvider = game:GetService('ContentProvider')

--// VARIABLES

local SoundDatabase = require(script.SoundDatabase)
local UrlDatabase = require(script.Parent.Parent.UrlDatabase)
local Environment = require(script.Parent.Parent.Environment.Environment)

local SoundModule = {}
SoundModule.__index = SoundModule

local ActiveTagName = 'ActiveSound'

local DefaultConfig
local ActiveMeta

--// FUNCTIONS

function InstantizeSound(Id, Meta, Config)

    local Sound = Instance.new('Sound')
    for PropertyName, Property in pairs(Config) do
        if Sound[PropertyName] then
            Sound[PropertyName] = Property
        end
    end
    Sound.SoundId = UrlDatabase.RobloxAssetPrefix .. Id
    Sound.Parent = Meta

    CollectionService:AddTag(Sound, ActiveTagName)

    return Sound

end

function InstantizeMetaPart(Vector)

    local MetaFolder = workspace:FindFirstChild('SoundMeta')
    if not MetaFolder then MetaFolder = Instance.new('Folder') MetaFolder.Name = 'SoundMeta' end

    local MetaPart = Instance.new('Part')
    MetaPart.Name = 'MetaPart'
    MetaPart.Anchored = true
    MetaPart.Size = Vector3.new(0, 0, 0)
    MetaPart.Position = Vector
    MetaPart.Transparency = 1
    MetaPart.CanCollide = false
    MetaPart.Massless = true
    MetaPart.Parent = MetaFolder

    return MetaPart

end

function SoundModule:PlaySound(IdOrName, PartOrVector3OrModel, OptionalConfig, DestroyAfterPlaying ) --/ DestroyAfterPlaying default true

    local ConfigToUse
    local IdToUse
    local MetaToUse

    if (not IdOrName) then error('IdOrName is nil!') return end

    if typeof(IdOrName) == 'string' then

        local Entry = SoundDatabase[IdOrName]
        if Entry then
            IdToUse = Entry.Id
        else
            error('The sound name specfied is not in the database. Add it or use a raw Id')
            return
        end

    elseif typeof(IdOrName) == 'number' then

        IdToUse = IdOrName

    end

    if (not PartOrVector3OrModel) then

        if ActiveMeta then
            MetaToUse = ActiveMeta
        else
            if Environment.IsClient == true then
                MetaToUse = nil
            else
                error('No PartOrVector3OrModel has been specified. Please set the active meta or supply this argument when calling SoundModule:PlaySound()')
                return
            end
        end

    elseif PartOrVector3OrModel then
        if typeof(PartOrVector3OrModel) == 'Instance' then
            if PartOrVector3OrModel:IsA('Model') then
                if PartOrVector3OrModel.PrimaryPart then
                    MetaToUse = PartOrVector3OrModel.PrimaryPart
                else
                    error('The primary part of the model meta you specified has not been specified. Please set it before calling SoundModule:PlaySound() on a model meta.')
                    return
                end
            else
                MetaToUse = PartOrVector3OrModel
            end
        elseif typeof(PartOrVector3OrModel) == 'Vector3' then
            InstantizeMetaPart(PartOrVector3OrModel)
        end
    end

    if DefaultConfig then
        if (not OptionalConfig) then
            ConfigToUse = DefaultConfig
        elseif OptionalConfig then
            ConfigToUse = OptionalConfig
        end
    elseif (not DefaultConfig) then
        if OptionalConfig then
            ConfigToUse = OptionalConfig
        elseif (not OptionalConfig) then
            ConfigToUse = {}
        end
    end

    local SoundObject = InstantizeSound(IdToUse, MetaToUse, ConfigToUse) 
    
    ContentProvider:PreloadAsync({SoundObject})

    if not MetaToUse then
        SoundService:PlayLocalSound(SoundObject)
        return SoundObject
    end

    SoundObject:Play()

    if DestroyAfterPlaying == true then
        SoundObject.Ended:Connect(function()
            SoundObject:Destroy()
        end)
    end

    return SoundObject

end

function SoundModule:StopAllSounds()

    local Tagged = CollectionService:GetTagged('ActiveSound')

    for _, Sound in pairs(Tagged) do
        Sound:Destroy()
    end

end

return SoundModule