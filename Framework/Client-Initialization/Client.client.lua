--[[
    Author: Rask/AfraiEda
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local Component = require(ReplicatedFirst.Framework.Extra.Component)
--= Framework =--
Framework:LoadAllConfigurations()
Framework.AddControllersDeep(game.ReplicatedFirst.Client.Controllers)
warn("---= Welcome " .. Players.LocalPlayer.Name .. "! =---")
Framework.Start()
    :andThen(function()
        Component.Auto(game.ReplicatedFirst.Client.Components)
    end)
    :catch(function(error)
        warn("---= ❌ Framework encountered an error during initialization ❌ =---")
        warn("Error details: " .. tostring(error))
    end)
