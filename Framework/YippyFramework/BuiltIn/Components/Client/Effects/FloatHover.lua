--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local FloatHover = {}
FloatHover.__index = FloatHover
FloatHover.Tag = "FloatHover"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function FloatHover.new(UI: UIBase)
    local self = setmetatable({}, FloatHover)
    self.UIFloat = UI
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.FrameEventPath = UI:GetAttribute("FrameEventPath")
    self.TimeTween = UI:GetAttribute("TimeTween") or 0.1
    self.MoveOffset = UI:GetAttribute("MoveOffset") or Vector2.new(0, 0)
    self.OriginalPosition = UI.Position
    self.TargetPosition = self.OriginalPosition + UDim2.new(self.MoveOffset.X, 0, self.MoveOffset.Y, 0)
    self.UIFrameEvent = Framework.BuiltInShared.Part:findInstanceByPath(self.UIFloat, self.FrameEventPath)
    if not self.UIFrameEvent then
        self.Logger:Warn(
            "[TAG FloatHover] FrameEventPath is invalid: " .. self.UIFloat.Name .. "-" .. self.FrameEventPath
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

function FloatHover:Destroy()
    self.MouseEnterEvent:Disconnect()
    self.MouseLeaveEvent:Disconnect()
    self.UIFrameEvent = nil
end

--= Methods =--

function FloatHover:Exist()
    return self.UIFrameEvent ~= nil
end

function FloatHover:MouseEnter()
    if not self:Exist() then
        return
    end
    Framework.BuiltInShared.Tween:InstantTween(self.UIFloat, { Time = self.TimeTween }, {
        Position = self.TargetPosition,
    })
end

function FloatHover:MouseLeave()
    if not self:Exist() then
        return
    end
    Framework.BuiltInShared.Tween:InstantTween(self.UIFloat, { Time = self.TimeTween }, {
        Position = self.OriginalPosition,
    })
end

return FloatHover
