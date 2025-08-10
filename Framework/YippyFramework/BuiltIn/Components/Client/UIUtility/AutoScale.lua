--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local AutoScale = {}
AutoScale.__index = AutoScale
AutoScale.Tag = "AutoScale"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function AutoScale.new(ui)
    local self = setmetatable({}, AutoScale)
    self.AutoScale = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.BaseScale = ui.Scale

    if not self.AutoScale:IsA("UIScale") then
        self.Logger:Warn("[TAG AutoScale] AutoScale is not a UIScale - " .. ui.Name)
        return self
    end

    game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self:AdjustScale()
    end)

    self:AdjustScale()
    return self
end

function AutoScale:Destroy() end

--= Methods =--

function AutoScale:GetAverage(vector: Vector2): number
    return (vector.X + vector.Y) / 2
end

function AutoScale:AdjustScale()
    local ratio = self.BaseScale / self.AverageStudioSize

    self.AutoScale.Scale = self.AverageSize * ratio
end

return AutoScale
