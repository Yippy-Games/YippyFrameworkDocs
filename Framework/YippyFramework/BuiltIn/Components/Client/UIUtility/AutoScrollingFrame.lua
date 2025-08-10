--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local AutoScrollingFrame = {}
AutoScrollingFrame.__index = AutoScrollingFrame
AutoScrollingFrame.Tag = "AutoScrollingFrame"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local STUDIO_SCREEN_SIZE = Vector2.new(1920, 1080)
--= Constructor =--

function AutoScrollingFrame.new(ui)
    local self = setmetatable({}, AutoScrollingFrame)
    self.AutoScrollingFrame = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.BaseScrollBarThickness = ui.ScrollBarThickness
    self.AverageStudioSize = self:GetAverage(STUDIO_SCREEN_SIZE)
    self.AverageSize = self:GetAverage(game.Workspace.CurrentCamera.ViewportSize)

    if not self.AutoScrollingFrame:IsA("ScrollingFrame") then
        self.Logger:Warn("[TAG AutoScrollingFrame] AutoScrollingFrame is not a ScrollingFrame - " .. ui.Name)
        return self
    end

    game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.AverageSize = self:GetAverage(game.Workspace.CurrentCamera.ViewportSize)
        self:AdjustScrollBarThickness()
    end)

    self:AdjustScrollBarThickness()
    return self
end

function AutoScrollingFrame:Destroy() end

--= Methods =--

function AutoScrollingFrame:GetAverage(vector: Vector2): number
    return (vector.X + vector.Y) / 2
end

function AutoScrollingFrame:AdjustScrollBarThickness()
    local ratio = self.BaseScrollBarThickness / self.AverageStudioSize

    self.AutoScrollingFrame.ScrollBarThickness = self.AverageSize * ratio
end

return AutoScrollingFrame
