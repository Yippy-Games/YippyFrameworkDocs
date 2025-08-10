--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local UIStroke = {}
UIStroke.__index = UIStroke
UIStroke.Tag = "UIStroke"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local STUDIO_SCREEN_SIZE = Vector2.new(1920, 1080)
--= Constructor =--

function UIStroke.new(ui: UIStroke)
    local self = setmetatable({}, UIStroke)
    self.UIStroke = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.OldThickness = ui.Thickness
    self.AverageStudioSize = self:GetAverage(STUDIO_SCREEN_SIZE)
    self.AverageSize = self:GetAverage(game.Workspace.CurrentCamera.ViewportSize)

    if not self.UIStroke:IsA("UIStroke") then
        self.Logger:Warn("[TAG UIStroke] UIStroke is not a UIStroke -" .. ui.Name)
        return self
    end

    game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.AverageSize = self:GetAverage(game.Workspace.CurrentCamera.ViewportSize)
        self:AdjustThickness()
    end)

    self:AdjustThickness()
    return self
end

function UIStroke:Destroy() end

--= Methods =--

function UIStroke:GetAverage(vector: Vector2): number
    return (vector.X + vector.Y) / 2
end

function UIStroke:AdjustThickness()
    local ratio = self.OldThickness / self.AverageStudioSize

    self.UIStroke.Thickness = self.AverageSize * ratio
end

return UIStroke
