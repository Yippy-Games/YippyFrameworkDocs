--[[
    Author: Rask/AfraiEda
    Creation Date: 01/06/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local RunService = game:GetService("RunService")
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
        return
    end
    self.PingEvent = Framework.BuiltInClient.Network.Channel("PingEvent")
    self.StatsNetwork = Framework.BuiltInClient.Network.Channel("StatsNetwork")

    self:CalculatePing()
    self:Update()
end

function GlobalStats:SetInfo(Type: string, Value: any)
    local InstanceReceiver = Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsInstanceReceiver
    if InstanceReceiver then
        InstanceReceiver:SetAttribute(Type, Value)
        return
    end
end

function GlobalStats:SetInfoServer(Type: string, Value: any)
    self.StatsNetwork:Fire("Set", Type, Value)
end

function GlobalStats:GetInfo(Type: string)
    local InstanceReceiver = Framework.FrameworkConfig.Settings.GlobalStats.GlobalStatsInstanceReceiver
    if InstanceReceiver then
        return InstanceReceiver:GetAttribute(Type)
    end
end

function GlobalStats:Update()
    local fps_table = {}
    local fpsstart = tick()
    local updateratefps = 0.6
    local average_amount = 5

    local pingstart = tick()
    local updatrateping = 5

    RunService.RenderStepped:Connect(function(frametime)
        if tick() >= fpsstart + (updateratefps / average_amount) then
            local fps = 1 / frametime
            table.insert(fps_table, fps)
        end
        if tick() >= fpsstart + updateratefps then
            fpsstart = tick()
            local current = 0
            local maxn = table.maxn(fps_table)
            for i = 1, maxn do
                current = current + fps_table[i]
            end
            local fps = math.floor(current / maxn)

            GlobalStats:SetInfo("FPS", fps)
            fps_table = {}
        end

        if self.PingEvent and tick() >= pingstart + updatrateping then
            pingstart = tick()
            self:CalculatePing()
        end
    end)
end

function GlobalStats:CalculatePing()
    local start = time()
    self.PingEvent:Invoke("Ping"):Await()
    local ping = math.floor(((time() - start) * 1000))
    GlobalStats:SetInfo("Ping", ping)
end

return GlobalStats
