--[[

// Animation.lua
// Provide a lightweight library for controlling all humanoid animations
// ** Filed on Trello, still an in-progress module
// @Vexitory
// 11.11.2020

]]

--// **** THIS PACKAGE HAS NOT BEEN TESTED YET AND IS NOT READY FOR DEPLOYMENT. DO NOT USE IT.

--// SERVICES

local ReplicatedStorage = game:GetService('ReplicatedStorage')

--// VARIABLES

local NetworkingModule = {}
NetworkingModule.__index = NetworkingModule
local IngestFolderName = 'RemoteIngest'

--// FUNCTIONS

local IngestFolder = ReplicatedStorage:FindFirstChild(IngestFolderName)

if not IngestFolder then

    IngestFolder = Instance.new('Folder')
    IngestFolder.Name = IngestFolderName
    IngestFolder.Parent = ReplicatedStorage

end

function FindFirstChildOfClassAndName(Obj, Class, Name)

    local Object
    local PotentialInstances = {}

    for _,v in pairs(Obj:GetChildren()) do
        if v:IsA(Class) then
            table.insert(PotentialInstances, v)
        end
    end

    for _,v in pairs(PotentialInstances) do
        if v.Name == Name then
            Object = v
            break
        end
    end

    return Object

end

function InstantizeRemote(Name, Type, Parent)

    local NewRemote = Instance.new('Remote' .. Type)
    NewRemote.Name = Name
    NewRemote.Parent = Parent
    return NewRemote

end

function NetworkingModule:Get(Name, Type, OptionalParent)

    local DirectoryToFetch
    local TypeToFetch = Type
    local RemoteName = Name
    local Remote

    if not OptionalParent then
        DirectoryToFetch = IngestFolder
        Remote = FindFirstChildOfClassAndName(DirectoryToFetch, 'Remote'..TypeToFetch, RemoteName)
    elseif OptionalParent then
        DirectoryToFetch = OptionalParent
        Remote = FindFirstChildOfClassAndName(DirectoryToFetch, 'Remote'..TypeToFetch, RemoteName)
    end

    if not Remote then
        Remote = InstantizeRemote(Name, Type, DirectoryToFetch)
    end

    return Remote

end

return NetworkingModule