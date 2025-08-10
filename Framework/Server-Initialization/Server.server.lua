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

--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local Component = require(ReplicatedFirst.Framework.Extra.Component)
--= Framework =--
Framework:LoadAllConfigurations()
Framework.AddServicesDeep(game.ServerScriptService.Server.Services)
warn(
    string.format(
        "---= %s Framework V-%s | Created by %s =---",
        Framework.FrameworkConfig.Settings.FrameworkSettings.Name,
        Framework.FrameworkConfig.Settings.FrameworkSettings.Version,
        Framework.FrameworkConfig.Settings.FrameworkSettings.Studio
    )
)
Framework.Start()
    :andThen(function()
        Component.Auto(game.ServerScriptService.Server.Components)
    end)
    :catch(function(error)
        warn("---= ❌ Framework encountered an error during initialization ❌ =---")
        warn("Error details: " .. tostring(error))
    end)
