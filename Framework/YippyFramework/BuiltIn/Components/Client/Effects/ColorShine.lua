--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ColorShine = {}
ColorShine.__index = ColorShine
ColorShine.Tag = "ColorShine"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ColorShine.new(ui: GuiObject)
    local self = setmetatable({}, ColorShine)
    self.UI = ui
    self.StartPos = Vector2.new(-1, 0)

    self.Gradient = self:Setup()
    self:Animate()
    return self
end

function ColorShine:Destroy() end

--= Methods =--

function ColorShine:Setup()
    if self.UI:FindFirstChildOfClass("UIGradient") then
        self.UI:FindFirstChildOfClass("UIGradient"):Destroy()
    end
    local UIGradient = Instance.new("UIGradient")

    self.Color = self.UI.ImageColor3
    self.UI.ImageColor3 = Color3.fromRGB(255, 255, 255)
    UIGradient.Rotation = 45
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, self.Color),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, self.Color),
    })
    UIGradient.Offset = self.StartPos
    UIGradient.Parent = self.UI
    return UIGradient
end

function ColorShine:Animate()
    while true do
        Framework.BuiltInShared.Tween:InstantTween(
            self.Gradient,
            { Time = 1.5, Direction = Enum.EasingDirection.Out, Style = Enum.EasingStyle.Circular },
            { Offset = Vector2.new(1, 0) }
        )
        task.wait(3)
        self.Gradient.Offset = self.StartPos
    end
end

return ColorShine
