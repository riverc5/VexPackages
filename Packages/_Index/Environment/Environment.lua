--[[

// Environment.lua
// Provides a straightforward way to validate the current environment of a script
// ** Filed on Trello, still an in-progress module
// @Vexitory
// 11.10.2020

]]

local RunService = game:GetService('RunService')

return {

    IsClient = RunService:IsClient(),
    IsServer = RunService:IsServer(),
    IsStudio = RunService:IsStudio(),
    IsRunning = RunService:IsRunning(),
    IsRunMode = RunService:IsRunMode(),
    IsEditMode = RunService:IsEdit()

}