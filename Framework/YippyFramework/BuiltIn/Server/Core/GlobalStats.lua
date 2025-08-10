--[[
    Author: Rask/AfraiEda
    Creation Date: 01/06/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local Https = game:GetService("HttpService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local GlobalStats = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--

--= Variables =--

function GlobalStats:Start()
    if not Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsEnabled then
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("GlobalStats is disabled. Check settings.")
        end
        return
    end

    self.PingEvent = Framework.BuiltInServer.Network.Channel("PingEvent")
    self.StatsNetwork = Framework.BuiltInServer.Network.Channel("StatsNetwork")

    self.StatsNetwork:On("Set", function(Player: Player, Type: string, Value: any)
        if not GlobalStats:HasPermission(Player) then
            return
        end
        self:SetInfo(Type, Value)
    end)

    self.PingEvent:On("Ping", function()
        return true
    end)

    GlobalStats:BuiltinCalculation()
end

function GlobalStats:HasPermission(Player: Player)
    if
        Player:GetRankInGroup(Framework.FrameworkConfig.Settings.FrameworkSettings.GroupId)
        >= Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsRankRequired
    then
        return true
    end
    return false
end

function GlobalStats:PlayerAdded(_: Player)
    if GlobalStats.country == nil then
        GlobalStats:BuiltinCalculation()
    end
end

function GlobalStats:SetInfo(Type: string, Value: any)
    local InstanceReceiver = Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsInstanceReceiver
    if InstanceReceiver then
        InstanceReceiver:SetAttribute(Type, Value)
        return
    end
end

function GlobalStats:GetInfo(Type: string)
    local InstanceReceiver = Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsInstanceReceiver
    if InstanceReceiver then
        return InstanceReceiver:GetAttribute(Type)
    end
end

function GlobalStats:BuiltinCalculation()
    coroutine.wrap(function()
        local success, Data = pcall(function()
            return Https:JSONDecode(Https:GetAsync("http://ip-api.com/json/"))
        end)

        if success and Data and Data.country then
            GlobalStats:SetInfo("Country", Data.country)
            GlobalStats.country = Data.country
        else
            GlobalStats:SetInfo("Country", "Unknown")
        end
    end)()
end

return GlobalStats
