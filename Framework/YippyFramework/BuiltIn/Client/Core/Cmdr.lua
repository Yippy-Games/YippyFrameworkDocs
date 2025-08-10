--[[
    Author: Rask/AfraiEda
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
--= Framework =--
local Cmdr = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--
local Client = Players.LocalPlayer
--= Variables =--
--= Functions =--

function Cmdr:Start()
    if not Framework.FrameworkConfig.Settings.Cmdr.CmdrEnabled then
        return
    end

    local CmdrClient = ReplicatedStorage:WaitForChild("CmdrClient")
    if not CmdrClient then
        error("CmdrClient module not found.")
    end
    local success, CmdrPackage = pcall(function()
        return require(CmdrClient)
    end)
    if not success then
        error("CmdrClient module not found.")
        return
    end

    local GroupRole
    local success2, _ = pcall(function()
        GroupRole = Client:GetRankInGroup(Framework.FrameworkConfig.Settings.FrameworkSettings.GroupId)
    end)

    if not success2 then
        return
    end
    if RunService:IsStudio() or GroupRole >= Framework.FrameworkConfig.Settings.Cmdr.CmdrRankRequired then
        CmdrPackage:SetActivationKeys({ Framework.FrameworkConfig.Settings.Cmdr.CmdrKey })
    end
end

return Cmdr
