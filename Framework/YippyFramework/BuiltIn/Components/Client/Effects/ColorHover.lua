--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ColorHover = {}
ColorHover.__index = ColorHover
ColorHover.Tag = "ColorHover"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ColorHover.new(UI: UIBase)
    local self = setmetatable({}, ColorHover)
    self.UIColor = UI
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.FrameEventPath = UI:GetAttribute("FrameEventPath")
    self.TimeTween = UI:GetAttribute("TimeTween") or 0.05
    self.Type = UI:GetAttribute("Type") or "None"
    self.IsUIGradientInfluenced = self:IsUIGradientInfluenced()
    self.TargetColor = UI:GetAttribute("TargetColor") or Color3.fromRGB(255, 255, 255)
    self.OriginalColor = self:GetColor()
    if self.IsUIGradientInfluenced and typeof(self.TargetColor) ~= "ColorSequence" then
        self.Logger:Warn("[TAG ColorHover] UIColor is Gradient influenced, but UIColor is not a ColorSequence")
        return self
    end
    self.UIFrameEvent = Framework.BuiltInShared.Part:findInstanceByPath(self.UIColor, self.FrameEventPath)
    if not self.UIFrameEvent then
        self.Logger:Warn(
            "[TAG ColorHover] FrameEventPath is invalid: " .. self.UIColor.Name .. "-" .. self.FrameEventPath
        )
        return self
    end

    self.MouseEnterEvent = self.UIFrameEvent.MouseEnter:Connect(function()
        self:MouseEnter()
    end)

    self.MouseLeaveEvent = self.UIFrameEvent.MouseLeave:Connect(function()
        self:MouseLeave()
    end)
    return self
end

function ColorHover:Destroy()
    self.MouseEnterEvent:Disconnect()
    self.MouseLeaveEvent:Disconnect()
    self.UIFrameEvent = nil
end

--= Methods =--

function ColorHover:Exist()
    return self.UIFrameEvent ~= nil
end

function ColorHover:IsUIGradientInfluenced()
    if self.UIColor:FindFirstChildOfClass("UIGradient") then
        self.Gradient = self.UIColor:FindFirstChildOfClass("UIGradient")
        return true
    end
    return false
end

function ColorHover:GetColor()
    if self.IsUIGradientInfluenced then
        return self.Gradient.Color
    end

    if self.Type == "Image" then
        return self.UIColor.ImageColor3
    elseif self.Type == "Text" then
        return self.UIColor.TextColor3
    elseif self.Type == "Background" then
        return self.UIColor.BackgroundColor3
    end

    if self.UIColor.ClassName == "Frame" then
        return self.UIColor.BackgroundColor3
    elseif self.UIColor.ClassName == "TextLabel" or self.UIColor.ClassName == "TextButton" then
        return self.UIColor.TextColor3
    elseif self.UIColor.ClassName == "ImageLabel" or self.UIColor.ClassName == "ImageButton" then
        return self.UIColor.ImageColor3
    end
end

function ColorHover:MouseEnter()
    if not self:Exist() then
        return
    end
    if self.IsUIGradientInfluenced then
        Framework.BuiltInShared.Tween:InstantTweenGradient(self.Gradient, { Time = self.TimeTween }, {
            Color = self.TargetColor,
        })
        return
    end

    if self.Type == "Image" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            ImageColor3 = self.TargetColor,
        })
        return
    elseif self.Type == "Text" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            TextColor3 = self.TargetColor,
        })
        return
    elseif self.Type == "Background" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            BackgroundColor3 = self.TargetColor,
        })
        return
    end

    if self.UIColor.ClassName == "Frame" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            BackgroundColor3 = self.TargetColor,
        })
    elseif self.UIColor.ClassName == "TextLabel" or self.UIColor.ClassName == "TextButton" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            TextColor3 = self.TargetColor,
        })
    elseif self.UIColor.ClassName == "ImageLabel" or self.UIColor.ClassName == "ImageButton" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            ImageColor3 = self.TargetColor,
        })
    end
end

function ColorHover:MouseLeave()
    if not self:Exist() then
        return
    end

    if self.IsUIGradientInfluenced then
        Framework.BuiltInShared.Tween:InstantTweenGradient(self.Gradient, { Time = self.TimeTween }, {
            Color = self.OriginalColor,
        })
        return
    end

    if self.Type == "Image" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            ImageColor3 = self.OriginalColor,
        })
        return
    elseif self.Type == "Text" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            TextColor3 = self.OriginalColor,
        })
        return
    elseif self.Type == "Background" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            BackgroundColor3 = self.OriginalColor,
        })
        return
    end

    if self.UIColor.ClassName == "Frame" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            BackgroundColor3 = self.OriginalColor,
        })
    elseif self.UIColor.ClassName == "TextLabel" or self.UIColor.ClassName == "TextButton" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            TextColor3 = self.OriginalColor,
        })
    elseif self.UIColor.ClassName == "ImageLabel" or self.UIColor.ClassName == "ImageButton" then
        Framework.BuiltInShared.Tween:InstantTween(self.UIColor, { Time = self.TimeTween }, {
            ImageColor3 = self.OriginalColor,
        })
    end
end

return ColorHover
